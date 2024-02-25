{ lib, config, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.services.cliphist;
in {
  options.frgd.services.cliphist = {
    enable = mkEnableOption "Enable Taskwarrior Sync service";
  };

  config = mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      systemdTarget = "sway-session.target";
    };
  };
}
