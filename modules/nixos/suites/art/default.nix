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
  cfg = config.frgd.suites.art;
in
{
  options.frgd.suites.art = with types; {
    enable = mkBoolOpt false "Whether or not to enable art configuration.";
  };

  config = mkIf cfg.enable {
    frgd = {
      apps = {
        #        gimp = enabled;
        inkscape = enabled;
        #        blender = enabled;
      };
    };
  };
}
