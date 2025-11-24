{ lib
, config
, pkgs
, ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.hyprland;
in
{
  options.frgd.desktop.hyprland = with types; {
    enable = mkBoolOpt false "Whether or not to enable the Hyprland window manager.";
  };

  config = mkIf cfg.enable (
    let

      sddm-theme = pkgs.where-is-my-sddm-theme.override {
        themeConfig.General = {
          passwordCursorColor = "#${colorScheme.palette.base0F}";
          passwordTextColor = "#${colorScheme.palette.base05}";
          passwordInputBackground = "#${colorScheme.palette.base00}";
          passwordInputBorderColor = "#${colorScheme.palette.base00}";
          wrongPasswordBorderColor = "#${colorScheme.palette.base08}";
          backgroundFill = "#${colorScheme.palette.base00}";
          basicTextColor = "#${colorScheme.palette.base05}";
        };
      };
    in
    {
      services.dbus.enable = true;

      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
      powerManagement = {
        enable = true;
        powerDownCommands = "hyprlock --immediate-render --no-fade-in";
      };

      security.pam.services.hyprlock = { };

      services = {
        displayManager.defaultSession = "hyprland";
        displayManager.sddm = {
          enable = true;
          wayland.enable = true;
          extraPackages = with pkgs; [
            kdePackages.qt5compat
            sddm-theme
          ];
          theme = "where_is_my_sddm_theme";
        };
      };

      environment = {
        # loginShellInit = ''
        #   if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
        #     exec Hyprland
        #   fi
        # ''; # Will automatically open Hyprland when logged into tty1
        #
        variables = {
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SESSION_TYPE = "wayland";
          XDG_SESSION_DESKTOP = "Hyprland";
        };
        systemPackages = with pkgs; [
          grim
          mpvpaper
          slurp
          swappy
          wl-clipboard
          wlr-randr
          alacritty
          kitty
          firefox
          # libsForQt5.polkit-kde-agent
          hyprpolkitagent
          hyprutils
          xorg.xeyes
          udiskie
          xdg-desktop-portal-gtk
          xdg-desktop-portal-xapp
          # GTK themes
          nwg-look
          gruvbox-dark-gtk
          sweet
          zuki-themes
          yaru-theme
          whitesur-icon-theme
          whitesur-gtk-theme
          stilo-themes
          wl-clipboard
          sddm-theme
        ];
      };

      frgd = {
        hardware = {
          audio = enabled;
        };
        desktop.addons = {
          # swaylock = enabled;
          # greetd = enabled;
          # waybar = enabled;
          # foot = enabled;
          # rofi = enabled;
          # xdg-portal = enabled;
        };
        user.extraGroups = [ "video" ];
      };
      services.udisks2 = enabled;
      programs = {
        hyprland = {
          enable = true;
        };
        light = enabled;
        dconf = enabled;
        udevil = enabled;
        thunar = {
          enable = true;
          plugins = with pkgs.xfce; [
            thunar-archive-plugin
            thunar-media-tags-plugin
            thunar-volman
          ];
        };
      };
    }
  );
}
