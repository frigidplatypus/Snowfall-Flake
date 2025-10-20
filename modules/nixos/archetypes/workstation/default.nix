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
  cfg = config.frgd.archetypes.workstation;
in
{
  options.frgd.archetypes.workstation = with types; {
    enable = mkBoolOpt false "Whether or not to enable the workstation archetype.";
  };

  config = mkIf cfg.enable {
    frgd = {
      suites = {
        common = enabled;
        desktop = enabled;
        development = enabled;
        # art = enabled;
        # video = enabled;
        # social = enabled;
        # media = enabled;
      };

      tools = {
        appimage-run = enabled;
      };
    };
  };
}
