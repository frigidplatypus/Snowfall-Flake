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
      themeFile = "gruvbox-dark";
      font = {
        #TODO add option to set fontsize per system
        name = "Fantasque Sans Mono";
        size = 12;
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
