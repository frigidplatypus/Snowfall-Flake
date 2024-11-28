{
  lib,
  config,
  ...
}:
with lib;
with lib.frgd;

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.security.sops;
in
{
  options.frgd.security.sops = {
    enable = mkEnableOption "Enable Taskwarrior Sync service";
    miniflux_config = {
      enable = mkBoolOpt false "Matrix Registration Shared Secret";
      path = mkOption {
        type = types.path;
        default = "${config.home.homeDirectory}/.config/cliflux/config.toml";
        description = "Path to the Miniflux configuration file";
      };

    };

  };

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = "/sops/keys.txt";
      defaultSopsFile = ./secrets.yaml;
      secrets.miniflux_config = mkIf cfg.miniflux_config.enable {
        path = cfg.miniflux_config.path;
      };
    };
  };
}
