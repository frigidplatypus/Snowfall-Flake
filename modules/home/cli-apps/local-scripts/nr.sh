# Load config file
if [ -f ~/.config/nr/nrrc ]; then
  source ~/.config/nr/nrrc
fi

# Set defaults
MAX_PARALLEL=${MAX_PARALLEL:-5}

# Parse options
dry_run=false
select_mode=false
notify_mode=false
build_mode=false
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
    --help)
      echo "Usage: nr [options] [hostname] [additional-args]"
      echo ""
      echo "Options:"
      echo "  --dry-run          Show what would be done without making changes"
      echo "  --select           Interactively select hosts to deploy to"
      echo "  --notify           Send ntfy.sh notification after bulk deployment"
      echo "  --build            Build systems without deploying"
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

    echo "Starting parallel deployment..."

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
        echo "Deploying to $host..."
        if nixos-rebuild switch --flake "$NH_FLAKE#$host" --target-host "root@$host" 2>&1 | nom; then
          echo "$host: SUCCESS"
          echo "$(date '+%Y-%m-%d %H:%M:%S') $host: SUCCESS" >> ~/.nr_deploy.log
          return 0
        else
          echo "$host: FAILED"
          echo "$(date '+%Y-%m-%d %H:%M:%S') $host: FAILED" >> ~/.nr_deploy.log
          return 1
        fi
      fi
    }

    # Run deployments with limited parallelism
    succeeded=0
    failed=0
    active_jobs=0
    pids=()
    for host in $deploy_systems; do
      deploy_host "$host" &
      pids+=($!)
      active_jobs=$((active_jobs + 1))

      # Wait if at max parallel
      if [ "$active_jobs" -ge "$MAX_PARALLEL" ]; then
        for pid in "${pids[@]}"; do
          if wait "$pid" 2>/dev/null; then
            succeeded=$((succeeded + 1))
          else
            failed=$((failed + 1))
          fi
        done
        pids=()
        active_jobs=0
      fi
    done

    # Wait for remaining
    for pid in "${pids[@]}"; do
      if wait "$pid" 2>/dev/null; then
        succeeded=$((succeeded + 1))
      else
        failed=$((failed + 1))
      fi
    done

    echo
    GUM_BIN style --foreground 212 --bold "Deployment Summary:"
    GUM_BIN style --foreground 2 "Succeeded: $succeeded"
    GUM_BIN style --foreground 1 "Failed: $failed"

    # Send notification if configured and --notify flag used
    if $notify_mode && [ -n "$NTFY_TOPIC" ]; then
      NTFY_SERVER=${NTFY_SERVER:-https://ntfy.sh}
      CURL_BIN -s -d "Deployment complete: $succeeded succeeded, $failed failed" "$NTFY_SERVER/$NTFY_TOPIC" >/dev/null 2>&1 || true
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
    echo "Deploying to remote system: $HOST"
    if nixos-rebuild switch --flake "$NH_FLAKE#$HOST" --target-host "root@$HOST" |& nom; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: SUCCESS" >> ~/.nr_deploy.log
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S') $HOST: FAILED" >> ~/.nr_deploy.log
     fi
  fi
fi