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
  cfg = config.frgd.desktop.addons.bemenu;
in
{
  options.frgd.desktop.addons.bemenu = with types; {
    enable = mkBoolOpt false "bemenu";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bemenu
    ];
  };
}
