{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.frgd) enabled;

  cfg = config.frgd.cli-apps.local-scripts;
in
{
  options.frgd.cli-apps.local-scripts = {
    enable = mkEnableOption "local-scripts";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        nix-output-monitor # Make sure nom is available
        (writeShellScriptBin "nr" ''
          #!/bin/bash
          if [ $# -eq 0 ]; then
            echo "Error: hostname is required for remote deployment"
            echo "Usage: nr <hostname> [additional-args]"
            echo "Example: nr server"
            echo "Example: nr tasks --show-trace"
            exit 1
          fi

          HOST="$1"
          shift

          echo "Deploying to remote system: $HOST"
          nixos-rebuild switch --flake ".#$HOST" --target-host "root@$HOST" "$@" |& nom
        '') # Common scripts for all systems
        (writeShellScriptBin "fu" ''
          #!/bin/bash
          cd ~/Snowfall-Flake/ || { echo "Error: Could not change to ~/Snowfall-Flake/"; exit 1; }
          nix flake update
        '')

        (writeShellScriptBin "fe" ''
          #!/bin/bash
          cd ~/Snowfall-Flake/ || { echo "Error: Could not change to ~/Snowfall-Flake/"; exit 1; }
          nvim .
        '')
      ]
      # Linux-only scripts
      ++ lib.optionals stdenv.isLinux [
        (writeShellScriptBin "fs" ''
          #!/bin/bash
          ${figlet}/bin/figlet $(hostname)
          sudo nixos-rebuild switch --flake ~/Snowfall-Flake/#
        '')
      ]
      # macOS-only scripts
      ++ lib.optionals stdenv.isDarwin [
        (writeShellScriptBin "ds" ''
          #!/bin/bash
          ${figlet}/bin/figlet $(hostname)
          sudo darwin-rebuild switch --flake ~/Snowfall-Flake/#
        '')
      ];
  };
}
