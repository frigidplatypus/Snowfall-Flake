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
in
{
  options.frgd.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable the niri home module.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      brightnessctl
      grim
      slurp
      wl-clipboard
      # Cursor / icon / GTK themes
      capitaine-cursors-themed
      gruvbox-dark-gtk
      gruvbox-plus-icons
      # Utilities
      clipse
      pamixer
      playerctl
      swappy
      udiskie
      xdg-desktop-portal-gtk
      xwayland-satellite-unstable
    ];

    gtk = {
      enable = true;
      cursorTheme = {
        name = "Capitaine Cursors (Gruvbox)";
        package = pkgs.capitaine-cursors-themed;
      };
      iconTheme = {
        name = "Gruvbox-Plus-Dark";
        package = pkgs.gruvbox-plus-icons;
      };
      theme = {
        name = "gruvbox-dark";
        package = pkgs.gruvbox-dark-gtk;
      };
    };

    frgd.desktop.addons.rofi = enabled;

  };
}
