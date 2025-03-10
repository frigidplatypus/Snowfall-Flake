{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

with lib.frgd;
let
  cfg = config.frgd.desktop.addons.rofi;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  options.frgd.desktop.addons.rofi = with types; {
    enable = mkBoolOpt false "rofi";
  };

  config = mkIf cfg.enable {

    home = {
      packages = with pkgs; [
        rofi-power-menu
        rofi-bluetooth
        rofi-calc
        rofi-systemd
        rofi-screenshot
        rofimoji
        rofi-games
      ];
    };

    programs = {
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        terminal = "${pkgs.ghostty}/bin/ghostty";
        location = "center";
        font = "FiraCode Nerd Font Mono 12";
        plugins = with pkgs; [
          rofi-power-menu
          rofi-bluetooth
          rofi-calc
          rofi-systemd
          rofi-screenshot
          rofimoji
          rofi-games
        ];
        theme = {
          "*" = {
            bg0 = mkLiteral "#${colorScheme.palette.base00}";
            bg1 = mkLiteral "#${colorScheme.palette.base07}";
            fg0 = mkLiteral "#${colorScheme.palette.base06}";
            fg1 = mkLiteral "#${colorScheme.palette.base09}";

            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@fg0";

            margin = 0;
            padding = 0;
            spacing = 0;
          };

          "element-icon, element-text, scrollbar" = {
            cursor = mkLiteral "pointer";
          };

          "window" = {
            # location = mkLiteral "northwest";
            width = mkLiteral "580px";
            x-offset = mkLiteral "8px";
            y-offset = mkLiteral "34px";

            background-color = mkLiteral "@bg0";
            border = mkLiteral "1px";
            border-color = mkLiteral "@bg1";
            border-radius = mkLiteral "6px";
          };

          "inputbar" = {
            spacing = mkLiteral "8px";
            padding = mkLiteral "4px 8px";
            children = mkLiteral "[ entry ]";
            background-color = mkLiteral "@bg0";
          };

          "entry, element-icon, element-text" = {
            vertical-align = mkLiteral "0.5";
          };

          "textbox" = {
            padding = mkLiteral "4px 8px";
            background-color = mkLiteral "@bg0";
          };

          "listview" = {
            padding = mkLiteral "4px 0px";
            lines = 8;
            columns = 1;
            scrollbar = true;
          };

          "element" = {
            padding = mkLiteral "4px 8px";
            spacing = mkLiteral "8px";
          };

          "element normal urgent" = {
            text-color = mkLiteral "@fg1";
          };

          "element normal active" = {
            text-color = mkLiteral "@fg1";
          };

          "element selected" = {
            text-color = mkLiteral "@bg0"; # 1
            background-color = mkLiteral "@fg1";
          };

          "element selected urgent" = {
            background-color = mkLiteral "@fg1";
          };

          "element-icon" = {
            size = mkLiteral "0.8em";
          };

          "element-text" = {
            text-color = mkLiteral "inherit";
          };

          "scrollbar" = {
            handle-width = mkLiteral "4px";
            handle-color = mkLiteral "@fg1";
            padding = mkLiteral "0 4px";
          };
        };
      };
    };
  };
}
