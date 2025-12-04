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
  cfg = config.frgd.desktop.addons.waybar;
  icon-size = "18"; # px
in
{
  options.frgd.desktop.addons.waybar = with types; {
    enable = mkBoolOpt false "Whether to enable Waybar in the desktop environment.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waybar
      pavucontrol
      wireplumber
    ];

    # Home-manager waybar config

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target = "sway-session.target"; # Needed for waybar to start automatically
      };

      settings = {
        Main = {
          layer = "top";
          position = "top";
          height = 40;
          tray = {
            spacing = 10;
          };
          modules-left = [
            "custom/menu"
            "hyprland/workspaces"
          ];
          modules-center = [ ];
          # modules-center = [ "hyprland/window" ];
          modules-right = [
            "network"
            # "custom/pad"
            "bluetooth"
            # "custom/pad"
            "pulseaudio"
            # "custom/pad"
            "idle_inhibitor"
            # "custom/pad"
            "battery"
            # "custom/pad"
            "tray"
            # "custom/pad"
            "clock"
          ];

          "custom/pad" = {
            format = "";
            tooltip = false;
          };
          "custom/menu" = {
            format = "<span font='${icon-size}'></span>";
            on-click = "${pkgs.rofi}/bin/rofi -show p -modi p:${pkgs.rofi-power-menu}/bin/rofi-power-menu -theme $HOME/.config/rofi/config.rasi";
            on-click-right = "";
            tooltip = false;
          };
          "hyprland/workspaces" = {
            "format" = "<sub>{icon} </sub><span font='${icon-size}'>{windows}</span>";
            "format-window-separator" = " ";
            "window-rewrite-default" = "";
            "window-rewrite" = {
              "title<.*youtube.*>" = ""; # Windows whose titles contain "youtube"
              "class<firefox>" = ""; # Windows whose classes are "firefox"
              "class<Google-Chrome>" = ""; # Windows whose classes are "firefox"
              "foot" = ""; # Windows that contain "foot" in either class or title. For optimization reasons, it will only match against a title if at least one other window explicitly matches against a title.
              "ghostty" = ""; # Windows that contain "foot" in either class or title. For optimization reasons, it will only match against a title if at least one other window explicitly matches against a title.
              "vscode" = "󰨞";
              "bluebubbles" = "";
              "obsidian" = "";
              "notes" = "";
            };
          };
          "hyprland/window" = {
            "format" = "{}";
            "rewrite" = {
              "(.*) — Mozilla Firefox" = "<span font='${icon-size}'></span> <span font='14'> $1</span>";
              "(.*) - fish" = "<span font='14'>> [$1]</span>";
            };
            "separate-outputs" = true;
          };
          clock = {
            format = " {:%I:%M }";
            tooltip-format = ''<tt>{calendar}</tt>'';
            #format-alt = "{:%A, %B %d, %Y} ";
          };
          "idle_inhibitor" = {
            "format" = "<span font='${icon-size}'>{icon}</span>";
            "format-icons" = {
              "activated" = "";
              "deactivated" = "";
            };
          };
          battery = {
            interval = 60;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% <span font='${icon-size}'>{icon}</span>";
            format-charging = "{capacity}% ";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
            max-length = 25;
          };
          bluetooth = {
            format = "<span font='${icon-size}'>{icon}</span>";
            format-alt = "bluetooth: {status}";
            interval = 30;
            format-icons = {
              enabled = "";
              disabled = "";
            };
            tooltip-format = "{status}";
          };
          network = {
            format-wifi = "<span font='${icon-size}'></span>";
            format-ethernet = " ";
            #format-ethernet = "<span font='11'></span> {ifname}: {ipaddr}/{cidr}";
            format-linked = "<span font='${icon-size}'>睊</span> {ifname} (No IP)";
            format-disconnected = "<span font='${icon-size}'>睊</span> Not connected";
            #format-alt = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format = "{essid} {ipaddr}/{cidr}";
            on-click-right = "${pkgs.foot}/bin/footclient -e wifitui";
          };
          pulseaudio = { 
            format = " {icon} ";
            format-bluetooth = "{icon} {volume}% {format_source} ";
            format-bluetooth-muted = " {volume}% {format_source} ";
            format-muted = "{format_source}";
            #format-source = "{volume}% <span font='11'></span>";
            format-source = "";
            format-source-muted = "";
            format-icons = {
              default = [
                ""
                ""
                ""
              ];
              headphone = "";
              #hands-free = "";
              #headset = "";
              #phone = "";
              #portable = "";
              #car = "";
            };
            tooltip-format = "{desc}, {volume}%";
            on-click = "${pkgs.pamixer}/bin/pamixer -t";
            on-click-right = "${pkgs.pamixer}/bin/pamixer --default-source -t";
            on-click-middle = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
          tray = {
            icon-size = 30;
          };
        };
      };

      style =
        #CSS
        ''
          * {
          	border: none;
            font-family: ${font-propo};
          	font-size: 22px;
          }

          button:hover {
          	background-color: rgba(80, 100, 100, 0.4);
            padding: 10px;
          }

          window#waybar {
          	background-color: #${colorScheme.palette.base00};
          	transition-property: background-color;
          	transition-duration: .5s;
          	border-bottom: none;
          }

          window#waybar.hidden {
          	opacity: 0.2;
          }

          #workspace,
          #mode,
          #clock,
          #pulseaudio,
          #custom-sink,
          #network,
          #mpd,
          #memory,
          #network,
          #window,
          #cpu,
          #disk,
          #battery,
          #bluetooth,
          #idle_inhibitor,
          #tray {
          	color: #${colorScheme.palette.base07};
            padding: 0px 16px 0px 16px;
          }

          #bluetooth {
            background-color: #${colorScheme.palette.base0D};
            color: #${colorScheme.palette.base00};
          }

          #pulseaudio {
            background-color: #${colorScheme.palette.base0E};
            color: #${colorScheme.palette.base00};
          }

          #network {
            background-color: #${colorScheme.palette.base0E};
            color: #${colorScheme.palette.base00};
          }

          #idle_inhibitor {
            background-color: #${colorScheme.palette.base0F};
            color: #${colorScheme.palette.base00};
          }

          #custom-menu {
          	color: #fe8019;
          	padding: 0px 10px 0px 16px;
          	background-clip: padding-box;
          }

          #battery {
            background-color: #${colorScheme.palette.base0B};
            color: #${colorScheme.palette.base00};
          }

          #workspaces button {
          	padding: 0px 10px;
          	background-clip: padding-box;
          	min-width: 10px;
          	color: #${colorScheme.palette.base06};
          }

          #workspaces button:hover {
          	background-color: rgba(0, 0, 0, 0.2);
          }

          /*#workspaces button.focused {*/
          #workspaces button.active {
          	color: #${colorScheme.palette.base09};
          	background-color: #${colorScheme.palette.base09};
          }

          #workspaces button.visible {
          	color: #${colorScheme.palette.base07};
          }

          #workspaces button.hidden {
          	color: #${colorScheme.palette.base09};
          }

          #battery.warning {
          	color: #${colorScheme.palette.base09};
          }

          #battery.critical {
          	color: #${colorScheme.palette.base08};
          }

          #battery.charging {
          	color: #${colorScheme.palette.base00};
          }
        '';
    };
  };

}
