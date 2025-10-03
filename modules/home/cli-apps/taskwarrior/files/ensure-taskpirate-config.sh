#!/usr/bin/env bash
# Ensure taskpirate config exists and the binary is available.
# Invoked as a Taskwarrior hook; must be fast and not fail build pipelines.

set -euo pipefail

# Resolve config dir
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
TP_DIR="$XDG_CONFIG_HOME/taskpirate"
TP_CONFIG="$TP_DIR/config.yaml"

# prefer shipping binary if present in PATH
TP_BIN="$(command -v taskpirate || true)"

# If not in PATH, try common absolute locations (home-manager installs put it in profile/bin)
if [ -z "$TP_BIN" ]; then
  if [ -x "${HOME}/.nix-profile/bin/taskpirate" ]; then
    TP_BIN="${HOME}/.nix-profile/bin/taskpirate"
  fi
fi

# Create config dir if missing
if [ ! -d "$TP_DIR" ]; then
  mkdir -p "$TP_DIR"
  chmod 0755 "$TP_DIR"
fi

# Create minimal config if missing (non-sensitive defaults)
if [ ! -f "$TP_CONFIG" ]; then
  cat > "$TP_CONFIG" <<'EOF'
# Minimal taskpirate config - customize as needed.
# See: https://github.com/tbabej/taskpirate
server:
  # leave blank to use local taskwarrior only
  url: ""
logging:
  level: info
hooks:
  enable: true
EOF
  chmod 0644 "$TP_CONFIG"
fi

# Optionally attempt a health-check if binary available
if [ -n "$TP_BIN" ] && [ -x "$TP_BIN" ]; then
  # run a lightweight command that should succeed quickly
  if ! "$TP_BIN" --version >/dev/null 2>&1; then
    echo "taskpirate present but --version failed" >&2
  fi
else
  echo "taskpirate CLI not in PATH; please ensure pkgs.frgd.taskpirate is installed in your home.packages" >&2
fi

# Always exit 0 so Taskwarrior won't abort on missing config in automated runs
exit 0
