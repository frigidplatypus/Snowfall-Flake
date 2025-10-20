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
  cfg = config.frgd.suites.emulation;
in
{
  options.frgd.suites.emulation = with types; {
    enable = mkBoolOpt false "Whether or not to enable emulation configuration.";
  };

  config = mkIf cfg.enable {
    frgd = {
      apps = {
        yuzu = enabled;
        dolphin = enabled;
      };
    };
  };
}
