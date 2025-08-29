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
      # themeFile = "Cobalt_Neon";
      # themeFile = "DesertNight";
      # themeFile = "Duotone_Dark";
      # themeFile = "Flat";
      # themeFile = "FunForrest";
      # themeFile = "Hipster_Green";
      # themeFile = "";
      # themeFile = "";
      # themeFile = "";
      # themeFile = "";
      # themeFile = "ToyChest";
      # themeFile = "shadotheme";
      # themeFile = "Sakura_Night";
      # themeFile = "Renault_Style_Light";
      # themeFile = "Renault_Style";
      # themeFile = "Neowave";
      # themeFile = "MonaLisa";
      themeFile = "Jackie_Brown";
      # themeFile = "IC_Orange_PPL";
      # themeFile = "Ciapre";
      # themeFile = "GoaBase";
      font = {
        #TODO add option to set fontsize per system
        name = "Fantasque Sans Mono";
        size = 24;
      };
      settings = {
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        tab_activity_symbol = "";
        hide_window_decoration = "yes";
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
