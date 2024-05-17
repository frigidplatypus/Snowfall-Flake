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
  cfg = config.frgd.cli-apps.wine;
in
{
  options.frgd.cli-apps.wine = with types; {
    enable = mkBoolOpt false "Whether or not to enable Wine.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      winePackages
      winetricks
      wine64Packages
    ];
  };
}
