{
  config,
  pkgs,
  options,
  lib,
  ...
}:
with lib;
with lib.frgd;
{

  # Ensure git is available in the ISO image so the profile script can clone
  environment.systemPackages = with pkgs; [ git ];

  # Create a small login script that clones the Snowfall-Flake repo once
  # into /root/Snowfall-Flake on the first interactive login.
  environment.etc."profile.d/clone-snowfall.sh" = {
    text = ''
          #!/bin/sh
          # Only run for interactive shells
          case "$-" in
            *i*) ;;
            *) return 0;;
          esac

          TARGET=/root/Snowfall-Flake
          REPO=https://github.com/frigidplatypus/Snowfall-Flake

          # Already cloned?
          [ -d "$TARGET" ] && return 0

          # If git isn't available, skip
          command -v git >/dev/null 2>&1 || return 0

          # Clone in background so login isn't blocked; shallow clone for speed
      (
        git clone --depth 1 "$REPO" "$TARGET" >/dev/null 2>&1 || true
      ) &
    '';
    mode = "0755";
  };

  frgd = {
    suites.installer = enabled;
  };
}
