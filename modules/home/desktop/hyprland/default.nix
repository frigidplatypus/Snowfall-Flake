{ config
, lib
, pkgs
, inputs
, ...
}:

with lib;
with lib.frgd;

let
  cfg = config.frgd.desktop.hyprland;
in
{
  options.frgd.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to enable hyprland.";
    cursorTheme = mkOpt str "Capitaine Cursors (Gruvbox)" "The cursor theme to use.";
    gtkTheme = mkOpt str "gruvbox-dark" "The GTK theme to use.";
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
        # GTK themes
        gruvbox-dark-gtk
        sweet
        zuki-themes
        yaru-theme
        whitesur-icon-theme
        whitesur-gtk-theme
        stilo-themes
        clipse
        wvkbd
        squeekboard
        hyprpolkitagent
        hyprpicker
        hyprtoolkit
        gruvbox-plus-icons
        # walker
      ];
    };
    #xdg.configFile."hypr/hyprland.conf".source = ./config;
    gtk = {
      cursorTheme.name = cfg.cursorTheme;
      enable = true;
      iconTheme.name = icon-theme;
      theme = {
        name = cfg.gtkTheme;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      plugins = with pkgs.hyprlandPlugins; [
        hyprfocus
        hyprgrass
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
          gesture = [
            "3, horizontal, workspace"
          ];
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
            "SUPER,Return,exec,${pkgs.foot}/bin/footclient"
            "SUPERSHIFT,Return,exec,${pkgs.firefox}/bin/firefox"
            "SUPERSHIFT,Q,killactive,"
            "SUPER,Escape,exit,"
            "SUPER,E,exec,${pkgs.nautilus}/bin/nautilus"
            "SUPER,H,togglefloating,"
            "SUPER,Space,exec,rofi -modi 'drun,calc,clipboard:cliphist-rofi-img,filebrowser' -show drun"
            "SUPER,P,pseudo,"
            "SUPER,F,fullscreen"
            "SUPER,R,forcerendererreload"
            "SUPERSHIFT,L,exec,${inputs.hyprlock.packages.${pkgs.system}.hyprlock}/bin/hyprlock"

            ",XF86AudioLowerVolume,exec,${pkgs.avizo}/bin/volumectl -u down"
            ",XF86AudioRaiseVolume,exec,${pkgs.avizo}/bin/volumectl -u up"
            ",XF86AudioMute,exec,${pkgs.avizo}/bin/volumectl toggle-mute"
            ",XF86AudioMicMute,exec,${pkgs.avizo}/bin/volumectl -m toggle-mute"
            ",XF86MonBrightnessDown,exec,${pkgs.avizo}/bin/lightctl down"
            ",XF86MonBrightnessUP,exec,${pkgs.avizo}/bin/lightctl up"
          ];
          windowrule = [
            # "match:float true, match:title ^(Volume Control)$"
            # "match:float true, match:title ^(Picture-in-Picture)$"
            # "match:pin true, match:title ^(Picture-in-Picture)$"
            # "move 75% 75%, match:title ^(Picture-in-Picture)$"
            # "size 24% 24%, match:title ^(Picture-in-Picture)$"
          ];
          # windowrulev2 = [ "float,class:(floating)" ]; # ensure you have defined a floating window class

          exec-once = [
            "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

            "${pkgs.clipse}/bin/clipse -listen"
            "${pkgs.wvkbd}/bin/wvkbd-mobintl --hidden"
            "${pkgs._1password-gui}/bin/1password --silent"
            # "${pkgs.waybar}/bin/waybar"
            "${pkgs.foot}/bin/foot --server &"
            "hyprctl setcursor 'Capitaine Cursors (Gruvbox)' 14"
            "${pkgs.mako}"
            "${pkgs.udiskie}/bin/udiskie --tray --notify"
            "systemctl --user start waybar"
            "systemctl --user start hyprpolkitagent"
            "systemctl --user start cliphist"
            "systemctl --user start hyprpaper"
            "systemctl --user start avizo"
          ];
        }

        cfg.extra-config
      ];
      extraConfig = ''
        bind=,print,exec,${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.swappy}/bin/swappy -f - -o ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png && notify-send "Saved to ~/Pictures/$(date +%Hh_%Mm_%Ss_%d_%B_%Y).png"

        # Lid switch handling removed here; prefer system-level handling or hypridle
        # (hypridle below will call hyprlock before suspend). If you still want
        # Hyprland to handle the lid switch, re-add a bindl but be aware it can
        # be unreliable and may conflict with systemd/logind.

        bindl=,XF86PowerOff,exec,systemctl suspend
      '';
    };
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          before_sleep_cmd = "${
            inputs.hyprlock.packages.${pkgs.system}.hyprlock
          }/bin/hyprlock --immediate-render --no-fade-in";
          # Ignore DBus inhibitors so hypridle can lock/suspend reliably when the lid closes.
          ignore_dbus_inhibit = true;
          lock_cmd = "pidof hyprlock || ${
            inputs.hyprlock.packages.${pkgs.system}.hyprlock
          }/bin/hyprlock --immediate-render --no-fade-in";
        };

        listener = [
          {
            timeout = 120;
            on-timeout = "${
              inputs.hyprlock.packages.${pkgs.system}.hyprlock
            }/bin/hyprlock --immediate-render --no-fade-in";
          }
          {
            timeout = 600;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 900;
            on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };

    services.swayosd = {
      enable = true;
      topMargin = 0.1;
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        spash = false;
        splash_offset = 2.0;

        preload = [
          "$HOME/flake/assets/wall.png"
        ];

        wallpaper = [
          "eDP-1,$HOME/flake/assets/wall.png"
        ];

      };
    };
    services.avizo.enable = true;
    services.avizo.settings = {
      default = {
        time = 1.0;
        "x-offset" = 0.5;
        "y-offset" = 0.1;
        "fade-in" = 0.1;
        "fade-out" = 0.2;
        padding = 10;
        # Use repo palette but render explicit rgba(...) strings (avizo docs
        # indicate rgba(...) is the documented format). This converts the
        # RRGGBB hex entries from `colorScheme.palette` into `rgba(r,g,b,a)`.
        background = hexToRgba colorScheme.palette.base00 0.9;
        "bar-fg-color" = hexToRgba colorScheme.palette.base06 1.0;
        "bar-bg-color" = hexToRgba colorScheme.palette.base01 0.6;
      };
    };

    # Hyprtoolkit theming for all hyprtoolkit-based apps (hyprlauncher, hyprlock, etc.)
    xdg.configFile."hypr/hyprtoolkit.conf" = {
      text = ''
        background = rgba(${colorScheme.palette.base00}AA)
        base = rgba(${colorScheme.palette.base01}AA)
        text = rgba(${colorScheme.palette.base05}FF)
        alternate_base = rgba(${colorScheme.palette.base02}FF)
        bright_text = rgba(${colorScheme.palette.base07}FF)
        accent = rgba(${colorScheme.palette.base0A}FF)
        accent_secondary = rgba(${colorScheme.palette.base0E}FF)
        font_family = ${font}
        font_family_monospace = ${font-mono}
      '';
    };

    frgd = {
      apps.foot = enabled;
      services.cliphist = enabled;
      desktop.addons = {
        waybar = enabled;
        swaylock = enabled;
        hyprlock = enabled;
        rofi = enabled;
        mako = enabled;
        hyprlauncher = enabled;
        ashell = enabled;
      };
    };
  };
}
