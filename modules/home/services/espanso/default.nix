{ config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.espanso;
in {
  options.frgd.services.espanso = with types; {
    enable = mkBoolOpt false "espanso";
    western_snippets = { enable = mkBoolOpt false "Enable Western snippets"; };

  };

  config = mkIf cfg.enable {
    services.espanso = mkIf pkgs.stdenv.isLinux enabled;

    home = { packages = with pkgs; [ espanso ]; };
    xdg.configFile."espanso/config/default.yml".source = ./config.yml;
    xdg.configFile."espanso/match/base.yml".source = ./base.yml;
    xdg.configFile."espanso/match/western.yml" =
      mkIf cfg.western_snippets.enable { source = ./western.yml; };

  };
}
