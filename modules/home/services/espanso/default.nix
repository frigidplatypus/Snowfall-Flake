{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.espanso;
in
{
  options.frgd.services.espanso = with types; {
    enable = mkBoolOpt false "espanso";
    western_snippets = {
      enable = mkBoolOpt false "Enable Western snippets";
    };
  };

  config = mkIf cfg.enable {
    services.espanso = {
      enable = mkIf pkgs.stdenv.isLinux true;
      #package = mkIf pkgs.stdenv.isLinux pkgs.espanso-wayland;
      configs = {
        default = {
          show_notifications = true;
          search_trigger = "off";
          #search_shortcut = "CTRL+SHIFT+SPACE";
          clipboard_threshold = 100;
        };
        foot = {
          filter_exec = "foot";
          backend = "Clipboard";
          paste_shortcut = "CTRL+SHIFT+V";
        };
      };
    };
    # home = { packages = with pkgs; [ espanso ]; };
    # xdg.configFile."espanso/config/default.yml".source = ./config.yml;
    xdg.configFile."espanso/match/base.yml".source = ./base.yml;
    xdg.configFile."espanso/match/western.yml" = mkIf cfg.western_snippets.enable {
      source = ./western.yml;
    };
  };
}
