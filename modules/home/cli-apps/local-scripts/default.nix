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
    flakePath = mkOpt str "/home/justin/flake" "Path to the NixOS flake.";
    remoteUser = mkOpt str "root" "User to use for remote deployment.";
    excludedHosts = mkOpt (listOf str) ["p5810"] "List of hosts to exclude from bulk deployments.";
    ntfyTopic = mkOpt (nullOr str) null "Topic for ntfy.sh notifications.";
    ntfyServer = mkOpt str "https://ntfy.sh" "Server for ntfy.sh notifications.";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        nix-output-monitor # Make sure nom is available
        gum
        jq
        curl
        (let
          gum = lib.getExe pkgs.gum;
          jq = lib.getExe pkgs.jq;
          curl = lib.getExe pkgs.curl;
          script = builtins.replaceStrings ["GUM_BIN" "JQ_BIN" "CURL_BIN"] ["${gum}" "${jq}" "${curl}"] (builtins.readFile ./nr.sh);
        in
          writeShellScriptBin "nr" ''${script}'')
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

    home.file.".config/nr/nrrc".text = ''
      EXCLUDED_HOSTS="${lib.concatStringsSep " " cfg.excludedHosts}"
      ${lib.optionalString (cfg.ntfyTopic != null) "NTFY_TOPIC=${cfg.ntfyTopic}"}
      NTFY_SERVER=${cfg.ntfyServer}
    '';

  };

}
