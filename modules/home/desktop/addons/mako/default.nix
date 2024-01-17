{ lib, config, pkgs, ... }:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.desktop.addons.mako;
in {
  options.frgd.desktop.addons.mako = { enable = mkEnableOption "mako"; };

  config = mkIf cfg.enable {

    home = { packages = with pkgs; [ libnotify ]; };
    services.mako = {
      enable = true;
      backgroundColor = "#${colorScheme.colors.base09}";
      borderColor = "#${colorScheme.colors.base0F}";
      defaultTimeout = 15000;
    };
  };
}
