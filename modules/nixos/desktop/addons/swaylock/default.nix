{ lib, config, pkgs, ... }:
with lib;
with lib.frgd;
let cfg = config.frgd.desktop.addons.swaylock;
in {
  options.frgd.desktop.addons.swaylock = {
    enable = mkEnableOption "Swaylock";
  };

  config = mkIf cfg.enable {
    security.pam.services.swaylock = { };
    powerManagement = {
      enable = true;
      powerDownCommands = "${pkgs.swaylock-effects}/bin/swaylock";
    };
  };

}
