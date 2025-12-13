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
  cfg = config.frgd.desktop.addons.hyprlauncher;
in
{
  options.frgd.desktop.addons.hyprlauncher = with types; {
    enable = mkBoolOpt false "hyprlauncher";
  };

  config = mkIf cfg.enable {
    services.hyprlauncher = {
      enable = true;
      settings = {
        general = {
          grab_focus = true;
        };
      };
    };
  };
}
