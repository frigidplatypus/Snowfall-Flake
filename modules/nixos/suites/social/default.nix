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
  cfg = config.frgd.suites.social;
in
{
  options.frgd.suites.social = with types; {
    enable = mkBoolOpt false "Whether or not to enable social configuration.";
  };

  config = mkIf cfg.enable {
    frgd = {
      apps = {
        # element = enabled;
      };
    };
  };
}
