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
        (writeShellScriptBin "clipboard" ''
          #!/bin/bash
           rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons
        '')

      ];
    };

    programs = {
      rofi = {
        enable = true;
        terminal = "${pkgs.foot}/bin/footclient";
        location = "center";
        font = "${font-mono} 12";
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

            bg0 = mkLiteral "#${colorScheme.palette.base00}"; # 282828
            bg1 = mkLiteral "#${colorScheme.palette.base01}";
            bg2 = mkLiteral "#${colorScheme.palette.base02}";
            bg3 = mkLiteral "#${colorScheme.palette.base09}";

            fg0 = mkLiteral "#${colorScheme.palette.base07}"; # fbf1c7
            fg1 = mkLiteral "#${colorScheme.palette.base06}";
            fg2 = mkLiteral "#${colorScheme.palette.base05}";
            fg3 = mkLiteral "#${colorScheme.palette.base03}";

            background-color = mkLiteral "transparent";
            text-color = mkLiteral "@fg0";

            margin = mkLiteral "0px";
            padding = mkLiteral "0px";
            spacing = mkLiteral "0px";
          };

          window = {
            location = mkLiteral "north";
            y-offset = mkLiteral "calc(50% - 176px)";
            width = mkLiteral "480px";
            border-radius = mkLiteral "12px";
            border-color = mkLiteral "@bg3";
            border = "2px";
            background-color = mkLiteral "@bg2";
          };

          mainbox = {
            padding = mkLiteral "12px";
          };

          inputbar = {
            background-color = mkLiteral "@bg1";
            border-color = mkLiteral "@bg3";

            border = mkLiteral "2px";
            border-radius = mkLiteral "16px";

            padding = mkLiteral "8px 16px";
            spacing = mkLiteral "8px";
            children = mkLiteral "[ prompt, entry ]";
          };

          prompt = {
            text-color = mkLiteral "@fg2";
          };

          entry = {
            placeholder = mkLiteral "\"Search\"";
            placeholder-color = mkLiteral "@fg3";
          };

          message = {
            margin = mkLiteral "12px 0 0";
            border-radius = mkLiteral "16px";
            border-color = mkLiteral "@bg2";
            background-color = mkLiteral "@bg2";
          };

          textbox = {
            padding = mkLiteral "8px 24px";
          };

          listview = {
            background-color = mkLiteral "transparent";

            margin = mkLiteral "12px 0 0";
            lines = 8;
            columns = 1;

            fixed-height = false;
          };

          element = {
            padding = mkLiteral "8px 16px";
            spacing = mkLiteral "8px";
            border-radius = mkLiteral "16px";
          };

          "element normal active" = {
            text-color = mkLiteral "@bg3";
          };

          "element alternate active" = {
            text-color = mkLiteral "@bg3";
          };

          "element selected normal, element selected active" = {
            background-color = mkLiteral "@bg3";
          };

          "element-icon" = {
            size = mkLiteral "1em";
            vertical-align = mkLiteral "0.5";
          };

          "element-text" = {
            text-color = mkLiteral "inherit";
          };
        };
      };
    };
  };
}
