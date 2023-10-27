{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.klipper;
in {
  options.frgd.services.klipper = with types; {
    enable = mkBoolOpt false "klipper";
  };

  config = mkIf cfg.enable {

    services.klipper = {
      enable = true;

      configFile = ./printer.cfg;
    };

    frgd = { services.moonraker = enabled; };

    services.fluidd = enabled;

  };
}
