{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.desktop.addons.waybar;
in {
  options.frgd.desktop.addons.waybar = with types; {
    enable =
      mkBoolOpt false "Whether to enable Waybar in the desktop environment.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ waybar pavucontrol wireplumber ];

    # Home-manager waybar config

    programs.waybar = {
      enable = true;
      systemd = {
        enable = true;
        target =
          "sway-session.target"; # Needed for waybar to start automatically
      };

      settings = {
        Main = {
          layer = "top";
          position = "top";
          height = 25;
          tray = { spacing = 15; };
          #modules-center = [ "clock" ];
          modules-left = [ "custom/menu" "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "network"
            "custom/pad"
            "bluetooth"
            "custom/pad"
            "pulseaudio"
            "custom/pad"
            "battery"
            "custom/pad"
            "clock"
            "tray"
          ];

          "custom/pad" = {
            format = " ";
            tooltip = false;
          };
          "custom/menu" = {
            format = "<span font='16'> </span>";
            on-click =
              "${pkgs.rofi}/bin/rofi -show p -modi p:${pkgs.rofi-power-menu}/bin/rofi-power-menu -theme $HOME/.config/rofi/config.rasi";
            on-click-right = "";
            tooltip = false;
          };
          clock = {
            format = "{:%b %d %I:%M}  ";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt>{calendar}</tt>'';
            #format-alt = "{:%A, %B %d, %Y} ";
          };
          battery = {
            interval = 60;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% <span font='14'>{icon}</span>";
            format-charging = "{capacity}% <span font='11'></span>";
            format-icons = [ "" "" "" "" "" ];
            max-length = 25;
          };
          bluetooth = {
            format = "{icon}";
            format-alt = "bluetooth: {status}";
            interval = 30;
            format-icons = {
              enabled = "";
              disabled = "";
            };
            tooltip-format = "{status}";
          };
          network = {
            format-wifi = "<span font='14'> </span>";
            format-ethernet = "<span font='14'> </span>";
            #format-ethernet = "<span font='11'></span> {ifname}: {ipaddr}/{cidr}";
            format-linked = "<span font='14'>睊</span> {ifname} (No IP)";
            format-disconnected = "<span font='14'>睊</span> Not connected";
            #format-alt = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format = "{essid} {ipaddr}/{cidr}";
            #on-click-right = "${pkgs.alacritty}/bin/alacritty -e nmtui";
          };
          pulseaudio = {
            format = "<span font='11'>{icon}</span> {volume}% {format_source} ";
            format-bluetooth =
              "<span font='11'>{icon}</span> {volume}% {format_source} ";
            format-bluetooth-muted =
              "<span font='11'></span> {volume}% {format_source} ";
            format-muted = "<span font='11'></span> {format_source} ";
            #format-source = "{volume}% <span font='11'></span>";
            format-source = "<span font='10'></span> ";
            format-source-muted = "<span font='11'> </span> ";
            format-icons = {
              default = [ "" "" "" ];
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
          tray = { icon-size = 13; };
        };
      };
      style = ''

        * {
        	border: none;
        	font-family: FiraCode Nerd Font Mono;
        	font-size: 14px;
        	text-shadow: 0px 0px 5px #000000;
        }

        button:hover {
        	background-color: rgba(80, 100, 100, 0.4);
        }

        window#waybar {
        	background-color: rgba(29, 32, 33, .9);
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
        #tray {
        	color: #999999;
        	background-clip: padding-box;
        }

        #custom-menu {
        	color: #fe8019;
        	padding: 0px 5px 0px 5px;
        }

        #workspaces button {
        	padding: 0px 5px;
        	min-width: 5px;
        	color: rgba(255, 255, 255, 0.8);
        }

        #workspaces button:hover {
        	background-color: rgba(0, 0, 0, 0.2);
        }

        /*#workspaces button.focused {*/
        #workspaces button.active {
        	color: rgba(255, 255, 255, 0.8);
        	background-color: rgba(213, 196, 161, 0.4);
        }

        #workspaces button.visible {
        	color: #ccffff;
        }

        #workspaces button.hidden {
        	color: #999999;
        }

        #battery.warning {
        	color: #ff5d17;
        }

        #battery.critical {
        	color: #ff200c;
        }

        #battery.charging {
        	color: #9ece6a;
        }
      '';
    };
  };

}
