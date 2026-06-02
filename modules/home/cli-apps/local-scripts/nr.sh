#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck source=/dev/null
source ~/.config/nr/nrrc
if [ -f ~/.config/nr/nrrc ]; then
	source ~/.config/nr/nrrc
fi

set -o pipefail

# Set defaults
HEALTH_CHECK_UNITS="${HEALTH_CHECK_UNITS:-network-online.target sshd.service systemd-resolved.service dbus.service}"
BUILD_TIMEOUT="${BUILD_TIMEOUT:-3600}"
LOG_FILE="${LOG_FILE:-$HOME/.nr_deploy.log}"
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=10"

# Parse options
dry_run=false
select_mode=false
notify_mode=false
build_mode=false
health_checks=true
strict_mode=false
verbose_mode=false
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
	--verbose)
		verbose_mode=true
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
		echo "  --verbose          Show log file paths and detailed info on failure"
		echo "  --help             Show this help message"
		echo ""
		echo "Environment Variables:"
		echo "  NH_FLAKE           Path to the Nix flake (required)"
		echo "  EXCLUDED_HOSTS     Space-separated list of hosts to exclude (default: p5810)"
		echo ""
		echo "Config File:"
		echo "  ~/.config/nr/nrrc  Bash file for persistent settings"
		echo "  HEALTH_CHECK_UNITS Space-separated list of units to check (default: network-online.target sshd.service systemd-resolved.service dbus.service)"
		echo "  BUILD_TIMEOUT      Timeout for nixos-rebuild build in seconds (default: 3600)"
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

log_msg() {
	local host="$1"
	local status="$2"
	echo "$(date '+%Y-%m-%d %H:%M:%S') $host: $status" >>"$LOG_FILE"
}

rotate_log() {
	if [ -f "$LOG_FILE" ]; then
		local line_count
		line_count=$(wc -l <"$LOG_FILE")
		if [ "$line_count" -gt 1000 ]; then
			tail -n 500 "$LOG_FILE" >"$LOG_FILE.tmp"
			mv "$LOG_FILE.tmp" "$LOG_FILE"
		fi
	fi
}

format_bytes() {
	local bytes=$1
	if command -v numfmt >/dev/null 2>&1; then
		numfmt --to=iec "$bytes" 2>/dev/null || echo "${bytes}B"
	else
		echo "${bytes}B"
	fi
}

deploy_host() {
	local host="$1"
	local start_time end_time elapsed
	local log_file exit_code

	start_time=$(date +%s)

	if "$build_mode"; then
		# ========== BUILD MODE ==========
		log_file="/tmp/nr-build-${host}.log"
		echo "Building system for $host..."

		timeout "$BUILD_TIMEOUT" nixos-rebuild build --flake "$NH_FLAKE#$host" 2>&1 | tee "$log_file" | nom
		exit_code=${PIPESTATUS[0]}

		if [ "$exit_code" -ne 0 ]; then
			echo "$host: BUILD FAILED (nixos-rebuild exited with code $exit_code)"
			if "$verbose_mode"; then
				echo "Build log: $log_file"
			fi
			log_msg "$host" "BUILD FAILED (rc=$exit_code)"
			return 1
		fi

		# Verify the result symlink was produced and is valid
		local result_link="result"
		if [ ! -L "$result_link" ]; then
			echo "$host: BUILD VERIFICATION FAILED - no 'result' symlink found in $(pwd)"
			echo "  The nixos-rebuild command exited 0 but did not produce a result symlink."
			if "$verbose_mode"; then
				echo "Build log: $log_file"
			fi
			log_msg "$host" "BUILD FAILED (no result symlink)"
			return 1
		fi

		# Verify result points to a valid store path
		local store_path
		store_path=$(readlink "$result_link" 2>/dev/null)
		if [ -z "$store_path" ]; then
			echo "$host: BUILD VERIFICATION FAILED - result symlink is empty"
			log_msg "$host" "BUILD FAILED (empty result)"
			return 1
		fi

		if [ ! -e "$store_path" ]; then
			echo "$host: BUILD VERIFICATION FAILED - result symlink points to non-existent path"
			echo "  Path: $store_path"
			log_msg "$host" "BUILD FAILED (result path missing: $store_path)"
			return 1
		fi

		# Query build size as additional confidence check
		local build_size
		build_size=$(nix-store --query --size "$store_path" 2>/dev/null || echo "0")
		if [ "$build_size" = "0" ] || [ -z "$build_size" ]; then
			echo "$host: BUILD WARNING - could not determine build size (nix-store query failed)"
		else
			local size_str
			size_str=$(format_bytes "$build_size")
			echo "$host: Build size: $size_str"
		fi

		end_time=$(date +%s)
		elapsed=$((end_time - start_time))

		echo "$host: BUILD SUCCESS (derivation: $store_path, time: ${elapsed}s)"
		log_msg "$host" "BUILD SUCCESS (derivation: $store_path, time: ${elapsed}s)"
		return 0

	else
		# ========== DEPLOY MODE ==========
		log_file="/tmp/nr-deploy-${host}.log"

		echo "Pre-check: Testing reachability of $host..."
		if ! ping -c 1 -W 5 "$host" >/dev/null 2>&1; then
			echo "$host: PRE-CHECK FAILED - unreachable"
			log_msg "$host" "PRE-CHECK FAILED (ping)"
			return 1
		fi

		# Capture pre-deploy generation for later comparison
		local pre_gen=""
		pre_gen=$(ssh $SSH_OPTS -o BatchMode=yes "root@$host" readlink /run/current-system 2>/dev/null || echo "")
		if [ -n "$pre_gen" ]; then
			echo "Pre-deploy generation: $pre_gen"
		else
			echo "Pre-deploy generation: unknown (could not determine via SSH)"
		fi

		echo "Deploying to $host..."
		nixos-rebuild switch --flake "$NH_FLAKE#$host" --target-host "root@$host" 2>&1 | tee "$log_file" | nom
		exit_code=${PIPESTATUS[0]}

		if [ "$exit_code" -ne 0 ]; then
			echo "$host: DEPLOY FAILED (nixos-rebuild exited with code $exit_code)"
			if "$verbose_mode"; then
				echo "Deploy log: $log_file"
			fi
			log_msg "$host" "DEPLOY FAILED (rc=$exit_code)"
			return 1
		fi

		# Verify generation changed after deploy — this is the strongest signal
		# that the new system actually took effect
		local post_gen=""
		post_gen=$(ssh $SSH_OPTS -o BatchMode=yes "root@$host" readlink /run/current-system 2>/dev/null || echo "")
		if [ -n "$post_gen" ]; then
			echo "Post-deploy generation: $post_gen"
			if [ -n "$pre_gen" ] && [ "$pre_gen" = "$post_gen" ]; then
				echo "$host: WARNING - generation unchanged after deploy (new system may not have taken effect)"
				if "$verbose_mode"; then
					echo "  Pre:  $pre_gen"
					echo "  Post: $post_gen"
				fi
				if "$strict_mode"; then
					log_msg "$host" "DEPLOY WARNING (gen unchanged)"
					return 1
				fi
			else
				echo "Generation changed - deploy confirmed ✓"
			fi
		else
			echo "Could not verify generation after deploy (SSH may be slow to respond)"
		fi

		# Verify SSH still works after deploy — an actual command, not just ping
		echo "Post-check: Verifying SSH connectivity to $host..."
		local ssh_check
		ssh_check=$(ssh $SSH_OPTS -o BatchMode=yes "root@$host" "hostname" 2>/dev/null) || true
		if [ -z "$ssh_check" ]; then
			echo "$host: POST-CHECK FAILED - SSH not working after deploy"
			if "$verbose_mode"; then
				echo "Deploy log: $log_file"
			fi
			if "$strict_mode"; then
				log_msg "$host" "POST-CHECK FAILED (SSH)"
				return 1
			fi
		else
			echo "SSH to $host working (hostname: $ssh_check) ✓"
		fi

		# Enhanced health checks
		if "$health_checks"; then
			echo "Health checks for $host..."

			# Check overall system state
			local system_state
			system_state=$(ssh $SSH_OPTS -o BatchMode=yes "root@$host" systemctl is-system-running 2>/dev/null || echo "unknown")
			case "$system_state" in
			running)
				echo "  System state: running ✓"
				;;
			degraded)
				echo "  WARNING: System state is 'degraded'"
				local failed_units
				failed_units=$(ssh $SSH_OPTS -o BatchMode=yes "root@$host" systemctl --failed --no-legend --no-pager 2>/dev/null || true)
				if [ -n "$failed_units" ]; then
					echo "  Failed units:"
					echo "$failed_units" | while IFS= read -r line; do echo "    $line"; done
				fi
				if "$strict_mode"; then
					log_msg "$host" "HEALTH WARNING (degraded system)"
					return 1
				fi
				;;
			*)
				echo "  System state: $system_state"
				;;
			esac

			# Check configured service units
			for unit in $HEALTH_CHECK_UNITS; do
				if ! ssh $SSH_OPTS -o BatchMode=yes "root@$host" systemctl is-active "$unit" >/dev/null 2>&1; then
					echo "  HEALTH WARNING - $unit is not active"
					if "$strict_mode"; then
						log_msg "$host" "HEALTH WARNING $unit"
						return 1
					fi
				fi
			done
		fi

		end_time=$(date +%s)
		elapsed=$((end_time - start_time))

		echo "$host: SUCCESS (time: ${elapsed}s)"
		log_msg "$host" "SUCCESS (time: ${elapsed}s)"
		return 0
	fi
}

if [ $# -eq 0 ]; then
	rotate_log

	EXCLUDED_HOSTS="${EXCLUDED_HOSTS:-p5810}"
	excluded_hosts="$(hostname) $EXCLUDED_HOSTS"
	excluded_hosts=$(echo "$excluded_hosts" | tr ' ' '\\n' | sort | uniq | tr '\\n' ' ' | xargs)
	GUM_BIN style --foreground 1 "Excluded hosts: $excluded_hosts"

	tmp_systems=$(mktemp)
	trap 'rm -f "$tmp_systems"' EXIT

	if GUM_BIN spin --title "Fetching available systems from flake..." -- sh -c "nix eval \\\"$NH_FLAKE#nixosConfigurations\\\" --apply builtins.attrNames --json 2>/dev/null | JQ_BIN -r .[] > $tmp_systems 2>/dev/null" && [ -s "$tmp_systems" ]; then
		systems=$(cat "$tmp_systems")
	else
		echo "Error: Failed to fetch systems from flake. Ensure NH_FLAKE is set and flake is valid."
		exit 1
	fi

	filtered_systems=$(echo "$systems" | grep -v -E "^(${excluded_hosts// /|})$")
	if [ -z "$filtered_systems" ]; then
		echo "All systems excluded. Nothing to deploy."
		exit 0
	fi

	if "$select_mode"; then
		deploy_systems=$(echo "$filtered_systems" | GUM_BIN filter --no-limit --placeholder "Select hosts to deploy to")
		if [ -z "$deploy_systems" ]; then
			echo "No hosts selected. Deployment cancelled."
			exit 0
		fi
	else
		deploy_systems="$filtered_systems"
	fi

	GUM_BIN style --foreground 212 --bold "Systems to deploy:"
	echo "$deploy_systems" | GUM_BIN style --foreground 99

	if GUM_BIN confirm --affirmative="Deploy All" --negative="Cancel" "Deploy to these systems?"; then
		if "$dry_run"; then
			echo "Dry run: Would $(if "$build_mode"; then echo build; else echo deploy; fi) to $(echo "$deploy_systems" | wc -l) systems"
			exit 0
		fi

		echo "Starting sequential deployment..."

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

		if "$notify_mode" && [ -n "$NTFY_TOPIC" ]; then
			NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"
			succeeded_list="${succeeded_hosts[*]}"
			failed_list="${failed_hosts[*]}"
			CURL_BIN -s -d "Deployment complete: Succeeded ${#succeeded_hosts[@]} ($succeeded_list), Failed ${#failed_hosts[@]} ($failed_list)" "$NTFY_SERVER/$NTFY_TOPIC" >/dev/null 2>&1 || true
		fi
	else
		echo "Deployment cancelled."
	fi
else
	rotate_log

	HOST="$1"
	shift

	tmp_hosts=$(mktemp)
	trap 'rm -f "$tmp_hosts"' EXIT

	if GUM_BIN spin --title "Validating hostname..." -- sh -c "nix eval \\\"$NH_FLAKE#nixosConfigurations\\\" --apply builtins.attrNames --json 2>/dev/null | JQ_BIN -r '.[]' > $tmp_hosts 2>/dev/null" && grep -q "^$HOST$" "$tmp_hosts" 2>/dev/null; then
		:
	else
		echo "Error: Host '$HOST' not found in flake configurations."
		exit 1
	fi

	if "$dry_run"; then
		echo "Dry run: Would $(if "$build_mode"; then echo build; else echo deploy; fi) $HOST"
		exit 0
	fi

	deploy_host "$HOST"
fi
