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

deploy_host() {
	local host="$1"
	if "$build_mode"; then
		echo "Building system for $host..."
		if timeout "$BUILD_TIMEOUT" nixos-rebuild build --flake "$NH_FLAKE#$host" 2>&1 | nom; then
			echo "$host: SUCCESS"
			log_msg "$host" "BUILD SUCCESS"
			return 0
		else
			echo "$host: FAILED"
			log_msg "$host" "BUILD FAILED"
			return 1
		fi
	else
		echo "Pre-check: Pinging $host..."
		if ! ping -c 1 -W 5 "$host" >/dev/null 2>&1; then
			echo "$host: PRE-CHECK FAILED - unreachable"
			log_msg "$host" "PRE-CHECK FAILED"
			return 1
		fi
		echo "Deploying to $host..."
		if ! output=$(nixos-rebuild switch --flake "$NH_FLAKE#$host" --target-host "root@$host" 2>&1 | nom); then
			echo "$host: DEPLOY FAILED"
			log_msg "$host" "DEPLOY FAILED"
			return 1
		fi
		if echo "$output" | grep -q "Finished at.*after"; then
			echo "$host: OUTPUT VALID - rebuild finished"
		else
			echo "$host: OUTPUT INVALID - rebuild did not finish properly"
			if "$strict_mode"; then
				log_msg "$host" "OUTPUT INVALID"
				return 1
			fi
		fi
		echo "Post-check: Pinging $host..."
		if ! ping -c 1 -W 10 "$host" >/dev/null 2>&1; then
			echo "$host: POST-CHECK FAILED - unreachable after deploy"
			if "$strict_mode"; then
				log_msg "$host" "POST-CHECK FAILED"
				return 1
			else
				echo "Continuing despite post-check failure..."
			fi
		fi
		if "$health_checks"; then
			echo "Health checks for $host..."
			for unit in $HEALTH_CHECK_UNITS; do
				if ! ssh $SSH_OPTS -o BatchMode=yes "root@$host" systemctl is-active "$unit" >/dev/null 2>&1; then
					echo "$host: HEALTH WARNING - $unit inactive"
					if "$strict_mode"; then
						log_msg "$host" "HEALTH WARNING $unit"
						return 1
					fi
				fi
			done
		fi
		echo "$host: SUCCESS"
		log_msg "$host" "SUCCESS"
		return 0
	fi
}

if [ $# -eq 0 ]; then
	rotate_log

	EXCLUDED_HOSTS="${EXCLUDED_HOSTS:-p5810}"
	excluded_hosts="$(hostname) $EXCLUDED_HOSTS"
	excluded_hosts=$(echo "$excluded_hosts" | tr ' ' '\n' | sort | uniq | tr '\n' ' ' | xargs)
	GUM_BIN style --foreground 1 "Excluded hosts: $excluded_hosts"

	tmp_systems=$(mktemp)
	trap 'rm -f "$tmp_systems"' EXIT

	if GUM_BIN spin --title "Fetching available systems from flake..." -- sh -c "nix eval \"$NH_FLAKE#nixosConfigurations\" --apply builtins.attrNames --json 2>/dev/null | JQ_BIN -r .[] > $tmp_systems 2>/dev/null" && [ -s "$tmp_systems" ]; then
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

	if GUM_BIN spin --title "Validating hostname..." -- sh -c "nix eval \"$NH_FLAKE#nixosConfigurations\" --apply builtins.attrNames --json 2>/dev/null | JQ_BIN -r '.[]' > $tmp_hosts 2>/dev/null" && grep -q "^$HOST$" "$tmp_hosts" 2>/dev/null; then
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
