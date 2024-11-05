{
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.apps.kitty;
in
{
  options.frgd.apps.kitty = with types; {
    enable = mkBoolOpt false "Whether or not to enable kitty.";
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      themeFile = "gruvbox-dark-hard";
      shellIntegration = {
        enableFishIntegration = true;
      };
    };
  };
}
