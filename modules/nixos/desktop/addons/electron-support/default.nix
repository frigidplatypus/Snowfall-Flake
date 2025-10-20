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
  cfg = config.frgd.desktop.addons.electron-support;
in
{
  options.frgd.desktop.addons.electron-support = with types; {
    enable = mkBoolOpt false "Whether to enable electron support in the desktop environment.";
  };

  config = mkIf cfg.enable {
    frgd.home.configFile."electron-flags.conf".source = ./electron-flags.conf;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
