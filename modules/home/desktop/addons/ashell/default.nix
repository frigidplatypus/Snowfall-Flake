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
  cfg = config.frgd.desktop.addons.ashell;
in
{
  options.frgd.desktop.addons.ashell = with types; {
    enable = mkBoolOpt false "ashell";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ashell
    ];

    programs.ashell = {
      enable = true;
      settings = {

        log_level = "warn";
        outputs = "Active";
        app_launcher_cmd = "hyprlauncher";

        modules = {
          left = [
            [
              "Workspaces"
            ]
          ];
          center = [ "WindowTitle" ];
          right = [
            "SystemInfo"
            [
              "Tray"
              "Privacy"
              "Settings"
              "Clock"
            ]
          ];
        };

        workspaces = {
          enable_workspace_filling = true;
        };

        CustomModule = [
          {
            name = "appLauncher";
            icon = "󱗼";
            command = "hyprlauncher";
          }
        ];

        window_title = {
          truncate_title_after_length = 100;
        };

        settings = {
          lock_cmd = "playerctl --all-players pause; nixGL hyprlock &";
          audio_sinks_more_cmd = "pavucontrol -t 3";
          audio_sources_more_cmd = "pavucontrol -t 4";
          wifi_more_cmd = "wifitui";
          # vpn_more_cmd = "nm-connection-editor";
          bluetooth_more_cmd = "bluetui";
        };

        appearance = {
          font_name = "${font-propo}";
          style = "Solid";
          scale_factor = 1.5;

          primary_color = "#${colorScheme.palette.base09}";
          success_color = "#${colorScheme.palette.base0B}";
          text_color = "#${colorScheme.palette.base05}";
          workspace_colors = [
            "#${colorScheme.palette.base09}"
            "#${colorScheme.palette.base0C}"
          ];
          # special_workspace_colors = [
          #   "#${colorScheme.palette.base0D}"
          #   "#${colorScheme.palette.base0E}"
          # ];

          danger_color = {
            base = "#${colorScheme.palette.base08}";
            weak = "#${colorScheme.palette.base0A}";
          };

          background_color = {
            base = "#${colorScheme.palette.base00}";
            weak = "#${colorScheme.palette.base01}";
            strong = "#${colorScheme.palette.base02}";
          };

          secondary_color = {
            base = "#${colorScheme.palette.base02}";
          };
        };

      };
    };
  };
}
