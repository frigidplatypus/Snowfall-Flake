{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.apps.inkscape;
in
{
  options.frgd.apps.inkscape = with types; {
    enable = mkBoolOpt false "Whether or not to enable Inkscape.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inkscape-with-extensions
      google-fonts
    ];
  };
}
