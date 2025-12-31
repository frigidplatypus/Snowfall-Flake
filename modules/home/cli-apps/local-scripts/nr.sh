# Load config file
if [ -f ~/.config/nr/nrrc ]; then
  source ~/.config/nr/nrrc
fi

# Set defaults

# Parse options
dry_run=false
select_mode=false
notify_mode=false
build_mode=false
health_checks=true
strict_mode=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      dry_run=true
      shift
      ;;
    --select)
      select_mode=true
      shift
      ;;
    --notify)
      notify_mode=true
      shift
      ;;
    --build)
      build_mode=true
      shift
      ;;
    --health-checks)
      health_checks=true
      shift
      ;;
    --no-health-checks)
      health_checks=false
      shift
      ;;
    --strict)
      strict_mode=true
      shift
      ;;
    --help)
      echo "Usage: nr [options] [hostname] [additional-args]"
      echo ""
      echo "Options:"
      echo "  --dry-run          Show what would be done without making changes"
      echo "  --select           Interactively select hosts to deploy to"
      echo "  --notify           Send ntfy.sh notification after bulk deployment"
      echo "  --build            Build systems without deploying"
      echo "  --health-checks    Enable post-deployment health checks (default)"
      echo "  --no-health-checks Disable post-deployment health checks"
      echo "  --strict           Fail deployment on health warnings"
      echo "  --help             Show this help message"
      echo ""
      echo "Environment Variables:"
      echo "  NH_FLAKE           Path to the Nix flake (required)"
      echo "  EXCLUDED_HOSTS     Space-separated list of hosts to exclude (default: p5810)"
      echo ""
      echo "Config File:"
      echo "  ~/.config/nr/nrrc  Bash file for persistent settings (e.g., MAX_PARALLEL=5)"
      echo ""
      echo "Examples:"
      echo "  nr --dry-run                   # Dry-run all eligible hosts"
      echo "  nr --select                    # Select and deploy to specific hosts"
      echo "  nr server                      # Deploy to 'server'"
      echo "  nr server --show-trace         # Deploy with additional nixos-rebuild args"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Usage: nr [--dry-run] [--select] [hostname] [additional-args]"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [ $# -eq 0 ]; then
  # Bulk deployment mode
  # Handle excluded hosts
  EXCLUDED_HOSTS="${EXCLUDED_HOSTS:-p5810}"
  excluded_hosts="$(hostname) $EXCLUDED_HOSTS"
  excluded_hosts=$(echo "$excluded_hosts" | tr ' ' '\n' | sort | uniq | tr '\n' ' ' | xargs)
  GUM_BIN style --foreground 1 "Excluded hosts: $excluded_hosts"

  if GUM_BIN spin --title "Fetching available systems from flake..." -- sh -c "nix eval \"$NH_FLAKE#nixosConfigurations\" --apply builtins.attrNames --json 2>/dev/null | JQ_BIN -r .[] > /tmp/nr_systems 2>/dev/null" && [ -s /tmp/nr_systems ]; then
    systems=$(cat /tmp/nr_systems)
  else
    echo "Error: Failed to fetch systems from flake. Ensure NH_FLAKE is set and flake is valid."
    rm -f /tmp/nr_systems
    exit 1
  fi
  rm -f /tmp/nr_systems

  # Filter out excluded hosts
  filtered_systems=$(echo "$systems" | grep -v -E "^(${excluded_hosts// /|})$")
  if [ -z "$filtered_systems" ]; then
    echo "All systems excluded. Nothing to deploy."
    exit 0
  fi

  # Select hosts if --select flag is used
  if $select_mode; then
    deploy_systems=$(echo "$filtered_systems" | GUM_BIN filter --no-limit --placeholder "Select hosts to deploy to")
    if [ -z "$deploy_systems" ]; then
      echo "No hosts selected. Deployment cancelled."
      exit 0
    fi
  else
    deploy_systems="$filtered_systems"
  fi

  # Display systems with gum styling
  GUM_BIN style --foreground 212 --bold "Systems to deploy:"
  echo "$deploy_systems" | GUM_BIN style --foreground 99

  # Confirm deployment
  if GUM_BIN confirm --affirmative="Deploy All" --negative="Cancel" "Deploy to these systems?"; then
    if $dry_run; then
      echo "Dry run: Would $(if $build_mode; then echo build; else echo deploy; fi) to $(echo "$deploy_systems" | wc -l) systems"
      exit 0
    fi

    echo "Starting sequential deployment..."

    # Function to deploy one host
    deploy_host() {
      host=$1
      if $build_mode; then
        echo "Building system for $host..."
        if nixos-rebuild build --flake "$NH_FLAKE#$host" 2>&1 | nom; then
          echo "$host: SUCCESS"
          echo "$(date '+%Y-%m-%d %H:%M:%S') $host: BUILD SUCCESS" >> ~/.nr_deploy.log
          return 0
        else
          echo "$host: FAILED"
          echo "$(date '+%Y-%m-%d %H:%M:%S') $host: BUILD FAILED" >> ~/.nr_deploy.log
          return 1
        fi
      else
        echo "Pre-check: Pinging $host..."
        if ! ping -c 1 -W 5 "$host" > /dev/null 2>&1; then
          echo "$host: PRE-CHECK FAILED - unreachable"
          echo "$(date '+%Y-%m-%d %H:%M:%S') $host: PRE-CHECK FAILED" >> ~/.nr_deploy.log
          return 1
        fi
        echo "Deploying to $host..."
        output=$(nixos-rebuild switch --flake "$NH_FLAKE#$host" --target-host "root@$host" 2>&1 | nom)
        if [ $? -ne 0 ]; then
          echo "$host: DEPLOY FAILED"
          echo "$(date '+%Y-%m-%d %H:%M:%S') $host: DEPLOY FAILED" >> ~/.nr_deploy.log
          return 1
        fi
        if echo "$output" | grep -q "Finished at.*after"; then
          echo "$host: OUTPUT VALID - rebuild finished"
        else
          echo "$host: OUTPUT INVALID - rebuild did not finish properly"
          if $strict_mode; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') $host: OUTPUT INVALID" >> ~/.nr_deploy.log
            return 1
          fi
        fi
        echo "Post-check: Pinging $host..."
        if ! ping -c 1 -W 10 "$host" > /dev/null 2>&1; then
          echo "$host: POST-CHECK FAILED - unreachable after deploy"
          if $strict_mode; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') $host: POST-CHECK FAILED" >> ~/.nr_deploy.log
            return 1
          else
            echo "Continuing despite post-check failure..."
          fi
        fi
        if $health_checks; then
          echo "Health checks for $host..."
          units=("network-online.target" "sshd.service" "systemd-resolved.service" "dbus.service" "nix-daemon.service")
          for unit in "${units[@]}"; do
            if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@"$host" systemctl is-active "$unit" > /dev/null 2>&1; then
              echo "$host: HEALTH WARNING - $unit inactive"
              if $strict_mode; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') $host: HEALTH WARNING $unit" >> ~/.nr_deploy.log
                return 1
              fi
            fi
          done
        fi
        echo "$host: SUCCESS"
        echo "$(date '+%Y-%m-%d %H:%M:%S') $host: SUCCESS" >> ~/.nr_deploy.log
        return 0
      fi
    }

    # Run deployments sequentially
    succeeded_hosts=()
    failed_hosts=()
    for host in $deploy_systems; do
      if deploy_host "$host"; then
        succeeded_hosts+=("$host")
      else
        failed_hosts+=("$host")
      fi
    done

    echo
    GUM_BIN style --foreground 212 --bold "Deployment Summary:"
    GUM_BIN style --foreground 2 "Succeeded: ${#succeeded_hosts[@]} (${succeeded_hosts[*]})"
    GUM_BIN style --foreground 1 "Failed: ${#failed_hosts[@]} (${failed_hosts[*]})"

    # Send notification if configured and --notify flag used
    if $notify_mode && [ -n "$NTFY_TOPIC" ]; then
      NTFY_SERVER=${NTFY_SERVER:-https://ntfy.sh}
      succeeded_list="${succeeded_hosts[*]}"
      failed_list="${failed_hosts[*]}"
      CURL_BIN -s -d "Deployment complete: Succeeded ${#succeeded_hosts[@]} ($succeeded_list), Failed ${#failed_hosts[@]} ($failed_list)" "$NTFY_SERVER/$NTFY_TOPIC" >/dev/null 2>&1 || true
    fi
  else
    echo "Deployment cancelled."
  fi
else
  # Single host deployment
  HOST="$1"
  shift

  # Validate hostname
  if GUM_BIN spin --title "Validating hostname..." -- sh -c "nix eval \"$NH_FLAKE#nixosConfigurations\" --apply builtins.attrNames --json 2>/dev/null | JQ_BIN -r '.[]' > /tmp/nr_hosts 2>/dev/null" && grep -q "^$HOST$" /tmp/nr_hosts 2>/dev/null; then
    rm -f /tmp/nr_hosts
  else
    echo "Error: Host '$HOST' not found in flake configurations."
    rm -f /tmp/nr_hosts
    exit 1
  fi

  if $dry_run; then
    echo "Dry run: Would $(if $build_mode; then echo build; else echo deploy; fi) $HOST"
    exit 0
  fi

  if $build_mode; then
    echo "Building system for $HOST"
    nixos-rebuild build --flake "$NH_FLAKE#$HOST" |& nom
  else
    echo "Pre-check: Pinging $HOST..."
    if ! ping -c 1 -W 5 "$HOST" > /dev/null 2>&1; then
      echo "$HOST: PRE-CHECK FAILED - unreachable"
      echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: PRE-CHECK FAILED" >> ~/.nr_deploy.log
      exit 1
    fi
    echo "Deploying to remote system: $HOST"
    output=$(nixos-rebuild switch --flake "$NH_FLAKE#$HOST" --target-host "root@$HOST" |& nom)
    if [ $? -ne 0 ]; then
      echo "$HOST: DEPLOY FAILED"
      echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: DEPLOY FAILED" >> ~/.nr_deploy.log
    else
      if echo "$output" | grep -q "Finished at.*after"; then
        echo "$HOST: OUTPUT VALID - rebuild finished"
      else
        echo "$HOST: OUTPUT INVALID - rebuild did not finish properly"
        if $strict_mode; then
          echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: OUTPUT INVALID" >> ~/.nr_deploy.log
          exit 1
        fi
      fi
      echo "Post-check: Pinging $HOST..."
      if ! ping -c 1 -W 10 "$HOST" > /dev/null 2>&1; then
        echo "$HOST: POST-CHECK FAILED - unreachable after deploy"
        if $strict_mode; then
          echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: POST-CHECK FAILED" >> ~/.nr_deploy.log
          exit 1
        else
          echo "Continuing despite post-check failure..."
        fi
      fi
      if $health_checks; then
        echo "Health checks for $HOST..."
        units=("network-online.target" "sshd.service" "systemd-resolved.service" "dbus.service" "nix-daemon.service")
        for unit in "${units[@]}"; do
          if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@"$HOST" systemctl is-active "$unit" > /dev/null 2>&1; then
            echo "$HOST: HEALTH WARNING - $unit inactive"
            if $strict_mode; then
              echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: HEALTH WARNING $unit" >> ~/.nr_deploy.log
              exit 1
            fi
          fi
        done
      fi
      echo "$HOST: SUCCESS"
      echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: SUCCESS" >> ~/.nr_deploy.log
    fi
  fi
fi