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
  cfg = config.frgd.desktop.xfce;
in
{
  options.frgd.desktop.xfce = with types; {
    enable = mkBoolOpt false "xfce";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
    };
    environment.systemPackages = with pkgs; [
      xfce.xfce4-whiskermenu-plugin
      xfce.gigolo
      xfce.catfish
      xfce.xfdashboard
      xfce.thunar-volman
      xfce.xfce4-appfinder
      xfce.xfce4-timer-plugin
      xfce.xfce4-weather-plugin
      xfce.xfce4-clipman-plugin
      xfce.xfce4-pulseaudio-plugin
      capitaine-cursors-themed
      gruvbox-dark-icons-gtk
      gruvbox-plus-icons
      gruvbox-gtk-theme
      gruvbox-dark-gtk
    ];
  };
}
