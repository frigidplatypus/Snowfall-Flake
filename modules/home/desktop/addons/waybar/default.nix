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
          height = 20;
          tray = { spacing = 15; };
          #modules-center = [ "clock" ];
          modules-left = [ "custom/menu" "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [
            "network"
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
            format = "<span font='16'></span>";
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
            format-wifi = "<span font='14'></span>";
            format-ethernet = "<span font='14'></span>";
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
          "custom/sink" = {
            format = "<span font='9'>蓼</span>";
            on-click = "$HOME/.config/waybar/script/sink.sh";
            tooltip = false;
          };
          tray = { icon-size = 13; };
        };
      };
    };
    home.file.".config/waybar/script/sink.sh" = {
      # Custom script: Toggle speaker/headset
      text = ''
        #!/bin/sh

        ID1=$(awk '/ Built-in Audio Analog Stereo/ {sub(/.$/,"",$2); print $2 }' <(${pkgs.wireplumber}/bin/wpctl status) | head -n 1)
        ID2=$(awk '/ S10 Bluetooth Speaker/ {sub(/.$/,"",$2); print $2 }' <(${pkgs.wireplumber}/bin/wpctl status) | sed -n 2p)

        HEAD=$(awk '/ Built-in Audio Analog Stereo/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | sed -n 2p)
        SPEAK=$(awk '/ S10 Bluetooth Speaker/ { print $2 }' <(${pkgs.wireplumber}/bin/wpctl status | grep "*") | head -n 1)

        if [[ $HEAD = "*" ]]; then
          ${pkgs.wireplumber}/bin/wpctl set-default $ID2
          echo -e "{\"text\":\""蓼"\"}"
        elif [[ $SPEAK = "*" ]]; then
          ${pkgs.wireplumber}/bin/wpctl set-default $ID1
          echo -e "{\"text\":\"""\"}"
        fi
      '';
      executable = true;
    };
  };

}
