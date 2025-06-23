{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
with lib.frgd;

let
  cfg = config.frgd.desktop.hyprland;
in
{
  options.frgd.desktop.hyprland = with types; {
    enable = mkBoolOpt false "hyprland";
    extra-config = mkOpt attrs { } "Extra configuration options for the install.";
  };

  config = mkIf cfg.enable {

    home = {
      packages = with pkgs; [
        capitaine-cursors-themed
        slurp
        brightnessctl
        #light
        swaylock-effects
        # pcmanfm
        pamixer
        grim
        swappy
        swaybg
        wofi
        swayidle
        xorg.xeyes
        xorg.xwininfo
        copyq
        # GTK themes
        gruvbox-dark-gtk
        sweet
        awf
        zuki-themes
        yaru-theme
        whitesur-icon-theme
        whitesur-gtk-theme
        stilo-themes
        clipse
        wvkbd
        squeekboard
        hyprpolkitagent
        # walker
      ];
    };
    #xdg.configFile."hypr/hyprland.conf".source = ./config;
    gtk = {
      cursorTheme.name = "Capitaine Cursors (Gruvbox)";
      enable = true;
      theme = {
        name = "gruvbox-dark";
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      plugins = with pkgs.hyprlandPlugins; [
        # hyprspace
        # hyprgrass
      ];
      settings = mkMerge [
        {
          general = {
            # sensitivity = 1;
            border_size = 4;
            gaps_in = 5;
            gaps_out = 5;
            layout = "dwindle";
            "col.active_border" = "rgba(${colorScheme.palette.base09}ff)";
            # col.inactive_border = "";
          };
          decoration = {
            rounding = 5;
          };
          animations = {
            enabled = true;
          };
          input = {
            kb_layout = "us";
            follow_mouse = 0;
            repeat_delay = 250;
            kb_options = "escape:nocaps";
            numlock_by_default = 0;
            force_no_accel = 1;
            sensitivity = 1.2;
            touchpad = {
              clickfinger_behavior = true;
              tap-to-click = true;
            };
          };
          dwindle = {
            pseudotile = false;
            force_split = 2;
          };
          gestures = {
            workspace_swipe = true;
            workspace_swipe_cancel_ratio = 0.15;
          };
          # plugin = {
          #   touch_gestures = {
          #     # swipe left from right edge
          #     hyprgrass-bind = [
          #       ", edge:r:l, workspace, +1"
          #       ", edge:l:r, workspace, -1"
          #
          #       # swipe up from bottom edge
          #       ", edge:u:d, exec, ${pkgs.nwg-drawer}/bin/nwg-drawer"
          #       ", edge:d:u, exec, ${pkgs.frgd.osk-toggle}/bin/osk-toggle"
          #
          #       # swipe down from left edge
          #       ", edge:l:d, exec, pactl set-sink-volume @DEFAULT_SINK@ -4%"
          #
          #       # swipe down with 4 fingers
          #       # NOTE: swipe events only trigger for finger count of >= 3
          #       ", swipe:4:d, killactive"
          #
          #       # swipe diagonally left and down with 3 fingers
          #       # l (or r) must come before d and u
          #       ", swipe:3:ld, exec, foot"
          #
          #       # tap with 3 fingers
          #       # NOTE: tap events only trigger for finger count of >= 3
          #       ", tap:3, exec, foot"
          #     ];
          #     # longpress can trigger mouse binds:
          #     hyprgrass-bindm = [
          #       ", longpress:2, movewindow"
          #       ", longpress:3, ${pkgs.wvkbd}/bin/wvkbd"
          #
          #     ];
          #   };
          # };
          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            force_default_wallpaper = 0;
          };
          bindm = [
            "SUPER,mouse:272,movewindow"
            "SUPER,mouse:273,resizewindow"
          ];
          bind = [
            # Change Focus
            "SUPER,left,movefocus,l"
            "SUPER,right,movefocus,r"
            "SUPER,up,movefocus,u"
            "SUPER,down,movefocus,d"

            # Move Windows
            "SUPERSHIFT,left,movewindow,l"
            "SUPERSHIFT,right,movewindow,r"
            "SUPERSHIFT,up,movewindow,u"
            "SUPERSHIFT,down,movewindow,d"

            "CTRL,right,resizeactive,20 0"
            "CTRL,left,resizeactive,-20 0"
            "CTRL,up,resizeactive,0 -20"
            "CTRL,down,resizeactive,0 20"
            #"SUPER, V, exec, ${pkgs.clipman}/bin/clipman pick -t ${pkgs.rofi}/bin/rofi"

            # Rofi Shortcuts
            "SUPER, C, exec, ${pkgs.rofi-wayland}/bin/rofi -show calc"

            # Change workspaces
            "SUPER,1,workspace,1"
            "SUPER,2,workspace,2"
            "SUPER,3,workspace,3"
            "SUPER,4,workspace,4"
            "SUPER,5,workspace,5"
            "SUPER,6,workspace,6"
            "SUPER,7,workspace,7"
            "SUPER,8,workspace,8"
            "SUPER,9,workspace,9"
            "SUPER,0,workspace,10"
            "SUPER,right,workspace,+1"
            "SUPER,left,workspace,-1"

            "SUPERSHIFT,1,movetoworkspace,1"
            "SUPERSHIFT,2,movetoworkspace,2"
            "SUPERSHIFT,3,movetoworkspace,3"
            "SUPERSHIFT,4,movetoworkspace,4"
            "SUPERSHIFT,5,movetoworkspace,5"
            "SUPERSHIFT,6,movetoworkspace,6"
            "SUPERSHIFT,7,movetoworkspace,7"
            "SUPERSHIFT,8,movetoworkspace,8"
            "SUPERSHIFT,9,movetoworkspace,9"
            "SUPERSHIFT,0,movetoworkspace,10"
            "SUPERSHIFT,right,movetoworkspace,+1"
            "SUPERSHIFT,left,movetoworkspace,-1"

            #"SUPER, V, exec,  ${pkgs.foot}/bin/footclient --class floating -e fish  -c '${pkgs.clipse}/bin/clipse $PPID'" # bind the open clipboard operation to a nice key.
            "SUPER,Return,exec,${inputs.ghostty.packages.x86_64-linux.default}/bin/ghostty"
            "SUPERSHIFT,Return,exec,${pkgs.firefox}/bin/firefox"
            "SUPERSHIFT,Q,killactive,"
            "SUPER,Escape,exit,"
            "SUPER,E,exec,${pkgs.nautilus}/bin/nautilus"
            "SUPER,H,togglefloating,"
            "SUPER,Space,exec,${pkgs.rofi-wayland}/bin/rofi -show drun"
            "SUPER,P,pseudo,"
            "SUPER,F,fullscreen"
            "SUPER,R,forcerendererreload"
            "SUPERSHIFT,L,exec,${pkgs.swaylock-effects}/bin/swaylock"

            ",XF86AudioLowerVolume,exec,${pkgs.avizo}/bin/volumectl -u down"
            ",XF86AudioRaiseVolume,exec,${pkgs.avizo}/bin/volumectl -u up"
            ",XF86AudioMute,exec,${pkgs.avizo}/bin/volumectl toggle-mute"
            ",XF86AudioMicMute,exec,${pkgs.avizo}/bin/volumectl -m toggle-mute"
            ",XF86MonBrightnessDown,exec,${pkgs.avizo}/bin/lightctl down"
            ",XF86MonBrightnessUP,exec,${pkgs.avizo}/bin/lightctl up"
          ];
          windowrule = [
            # "float,^(Rofi)$"
            "float,title:^(Volume Control)$"
            "float,title:^(Picture-in-Picture)$"
            "pin,title:^(Picture-in-Picture)$"
            "move 75% 75% ,title:^(Picture-in-Picture)$"
            "size 24% 24% ,title:^(Picture-in-Picture)$"
          ];
          windowrulev2 = [ "float,class:(floating)" ]; # ensure you have defined a floating window class

          exec-once = [
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
            # "${pkgs.swaybg}/bin/swaybg -m center -i $HOME/Snowfall-Flake/assets/wall.png"
            "${pkgs.clipse}/bin/clipse -listen"
            "${pkgs.wvkbd}/bin/wvkbd-mobintl --hidden"

            # "${pkgs.walker}/bin/walker --gapplication-service"

            "${pkgs.waybar}/bin/waybar"
            "${pkgs.foot}/binfoot --server &"
            #"${pkgs.swayidle}/bin/swayidle -w & disown"
            #"${pkgs.swayidle}/bin/swayidle -w timeout 300 'swaylock' timeout 600 'hyprctl dispatch dpms' timeout 1000 'systemctl suspend' resume 'hyprctl dispatch dpms on'"
            "hyprctl setcursor 'Capitaine Cursors (Gruvbox)' 14"
            "${pkgs.mako}"
            # "${pkgs.libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1"
            # "${pkgs.hyprpolkitagent}/bin/hyprpolkitagent"
            "${pkgs.udiskie}/bin/udiskie --tray --notify"
            "${pkgs.copyq}/bin/copyq --start-server"
            "systemctl --user start hyprpolkitagent"
          ];
        }

        cfg.extra-config
      ];
      extraConfig = ''
        bind=,print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f - -o ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png && notify-send "Saved to ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png"

        # Suspend when laptop is closed
        bindl=,switch:[Lid Switch],exec, "systemctl suspend"
      '';
    };
    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 120;
          command = "${pkgs.swaylock-effects}/bin/swaylock -fF --config ~/.config/swaylock/config";
        }
        {
          timeout = 600;
          command = "hyprctl dispatch dpms";
        }
        {
          timeout = 900;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];

      events = [
        {
          event = "before-sleep";
          command = "${pkgs.swaylock-effects}/bin/swaylock -fF --config ~/.config/swaylock/config";
        }
        {
          event = "after-resume";
          command = "hyprctl dispatch dpms on";
        }
        {
          event = "lock";
          command = "lock";
        }
      ];
    };

    services.swayosd = {
      enable = true;
      topMargin = 0.3;
    };

    # programs.walker = {
    #   enable = true;
    #   runAsService = true;
    # };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        spash = false;
        splash_offset = 2.0;

        preload = [
          "$HOME/Snowfall-Flake/assets/wall.png"
          # ../../../../assets/wall.png
        ];

        wallpaper = [
          "eDP-1,$HOME/Snowfall-Flake/assets/wall.png"
          # ../../../../assets/wall.png
        ];

      };
    };
    services.avizo.enable = true;
    services.wob.enable = true;
    frgd = {
      apps.foot = enabled;
      services.cliphist = enabled;
      # services.xremap = enabled;
      desktop.addons = {
        waybar = enabled;
        swaylock = enabled;
        rofi = enabled;
        # bemenu = enabled;
        mako = enabled;
      };
    };
  };
}
