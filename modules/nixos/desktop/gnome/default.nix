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
  cfg = config.frgd.desktop.gnome;
in
{
  options.frgd.desktop.gnome = with types; {
    enable = mkBoolOpt false "gnome";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    # services.xserver.displayManager.gdm.wayland = true;
    services.xserver.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      capitaine-cursors-themed
      gruvbox-dark-icons-gtk
      gruvbox-plus-icons
      gruvbox-gtk-theme
      gruvbox-dark-gtk
    ];
  };
}
