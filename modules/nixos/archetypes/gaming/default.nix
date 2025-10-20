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
  cfg = config.frgd.archetypes.gaming;
in
{
  options.frgd.archetypes.gaming = with types; {
    enable = mkBoolOpt false "Whether or not to enable the gaming archetype.";
  };

  config = mkIf cfg.enable {
    frgd.suites = {
      common = enabled;
      desktop = enabled;
      games = enabled;
    };
  };
}
