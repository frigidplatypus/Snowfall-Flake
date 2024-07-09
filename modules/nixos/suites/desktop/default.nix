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
  cfg = config.frgd.suites.desktop;
in
{
  options.frgd.suites.desktop = with types; {
    enable = mkBoolOpt false "Whether or not to enable common desktop configuration.";
    hyprland = mkBoolOpt false "Whether or not to enable hyprland.";
    gnome = mkBoolOpt false "Whether or not to enable gnome.";
    plasma = mkBoolOpt false "Whether or not to enable plasma.";
    xfce = mkBoolOpt false "Whether or not to enable xfce.";

  };

  config = mkIf cfg.enable {
    frgd = {
      desktop = {
        gnome = mkIf cfg.gnome enabled;
        hyprland = mkIf cfg.hyprland enabled;
        plasma = mkIf cfg.plasma enabled;
        xfce = mkIf cfg.xfce enabled;
        #        addons = { wallpapers = enabled; };
      };
      hardware = {
        # audio = enabled;
      };
      suites = {
        common = enabled;
      };
      services = {
        printing = enabled;
      };
      apps = {
        _1password = enabled;
        vlc = enabled;
        cider = enabled;
        firefox = enabled;
        vscode = enabled;
        # logseq = enabled;
        # pocketcasts = enabled;
        # yt-music = enabled;
        # gparted = enabled;
      };
    };
  };
}
