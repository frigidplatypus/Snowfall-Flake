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
      font = {
        name = "Anonymous Pro for Powerline";
        size = 18;
      };
      settings = {
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        tab_activity_symbol = "";
      };
      shellIntegration = {
        enableFishIntegration = true;
      };
      darwinLaunchOptions = [
        "--single-instance"
      ];
    };
  };
}
