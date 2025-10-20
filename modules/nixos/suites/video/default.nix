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
  cfg = config.frgd.suites.video;
in
{
  options.frgd.suites.video = with types; {
    enable = mkBoolOpt false "Whether or not to enable video configuration.";
  };

  config = mkIf cfg.enable {
    frgd = {
      apps = {
        #        pitivi = enabled;
        #        obs = enabled;
      };
    };
  };
}
