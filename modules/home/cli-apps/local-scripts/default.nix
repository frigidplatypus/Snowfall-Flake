{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.local-scripts;
in
{
  options.frgd.cli-apps.local-scripts = with types; {
    enable = mkBoolOpt false "Whether or not to enable local-scripts.";
  # Use an absolute path by default so shell tilde-expansion issues don't
  # cause tools (like deploy scripts) to pass a literal '~' into nix.
  flakePath = mkOpt str "/home/justin/Snowfall-Flake" "Path to the NixOS flake.";
    remoteUser = mkOpt str "root" "User to use for remote deployment.";
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
          nixos-rebuild switch --flake "${cfg.flakePath}#$HOST" --target-host "${cfg.remoteUser}@$HOST" "$@" |& nom
        '') # Common scripts for all systems
        (writeShellScriptBin "fu" ''
          #!/bin/bash
          cd ${cfg.flakePath} || { echo "Error: Could not change to ${cfg.flakePath}"; exit 1; }
          nix flake update
        '')

        (writeShellScriptBin "fe" ''
          #!/bin/bash
          cd ${cfg.flakePath} || { echo "Error: Could not change to ${cfg.flakePath}"; exit 1; }
          nvim .
        '')
      ]
      # Linux-only scripts
      ++ lib.optionals stdenv.isLinux [
        (writeShellScriptBin "fs" ''
          #!/bin/bash
          ${figlet}/bin/figlet $(hostname)
          sudo nixos-rebuild switch --flake ${cfg.flakePath}/#
        '')
      ]
      # macOS-only scripts
      ++ lib.optionals stdenv.isDarwin [
        (writeShellScriptBin "ds" ''
          #!/bin/bash
          ${figlet}/bin/figlet $(hostname)
          sudo darwin-rebuild switch --flake ${cfg.flakePath}/#
        '')
      ];
  };
}
