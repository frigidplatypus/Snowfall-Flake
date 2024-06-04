{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.esphome;
in
{
  options.frgd.services.esphome = with types; {
    enable = mkBoolOpt false "Whether or not to enable esphome.";
  };

  config = mkIf cfg.enable {
    services.esphome = {
      enable = true;
      address = "0.0.0.0";
      openFirewall = true;
    };
  };
}
