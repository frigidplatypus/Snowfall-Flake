{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.niri;
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
  options.frgd.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable the niri window manager.";
  };

  config = mkIf cfg.enable {

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };

    programs.dms-shell = {
      enable = true;
    };

    services.dbus.enable = true;

    powerManagement = {
      enable = true;
      powerDownCommands = "hyprlock --immediate-render --no-fade-in";
    };

    security.pam.services.hyprlock = { };

    services = {
      displayManager.defaultSession = "niri";
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

    environment.systemPackages = [ sddm-theme ];

    frgd.user.extraGroups = [ "video" ];

  };
}
