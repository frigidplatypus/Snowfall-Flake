{
  options,
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.cosmic;
in
{
  options.frgd.desktop.cosmic = with types; {
    enable = mkBoolOpt false "cosmic";
  };

  config = mkIf cfg.enable {
    # services.xserver.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager = {

      cosmic = {
        enable = true;
        xwayland = enabled;
      };
    };

  };
}
