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
  cfg = config.frgd.desktop.addons.swappy;
in
{
  options.frgd.desktop.addons.swappy = with types; {
    enable = mkBoolOpt false "Whether to enable Swappy in the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ swappy ];

    frgd.home.configFile."swappy/config".source = ./config;
    frgd.home.file."Pictures/screenshots/.keep".text = "";
  };
}
