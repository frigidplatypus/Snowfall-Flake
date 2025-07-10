{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.frgd) enabled;

  cfg = config.frgd.cli-apps.cria;
in
{
  options.frgd.cli-apps.cria = {
    enable = mkEnableOption "cria";
    apiUrl = lib.mkOption {
      type = lib.types.str;
      description = "Cria API URL";
    };
    apiKey = lib.mkOption {
      type = lib.types.str;
      description = "Cria API key (overridden by apiKeyFile if set)";
      default = null;
    };
    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "Path to file containing Cria API key (takes precedence over apiKey)";
      default = null;
    };
    defaultProject = lib.mkOption {
      type = lib.types.str;
      description = "Default project";
      default = "Inbox";
    };
    quick_actions = lib.mkOption {
      type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
      default = [ ];
      description = ''
        List of shortcut mappings for cria.

        Example:
          [
            {
              key = "w";
              action = "project";
              target = "Work";
            }
          ]
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ inputs.cria.packages.${system}.default ];
    home.file.".config/cria/config.yaml".text = ''
      api_url: ${cfg.apiUrl}
      ${
        if cfg.apiKeyFile != null && cfg.apiKeyFile != "" then
          "api_key_file: ${cfg.apiKeyFile}"
        else
          "api_key: ${cfg.apiKey}"
      }
      default_project: ${cfg.defaultProject}
      quick_actions:
      ${lib.concatMapStringsSep "\n" (s: ''
        - key: ${s.key}
          action: ${s.action}
          target: ${s.target}
      '') cfg.quick_actions}
    '';
  };
}
