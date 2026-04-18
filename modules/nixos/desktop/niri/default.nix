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
    enable = mkBoolOpt false "niri";
  };

  config = mkIf cfg.enable {

    programs.niri = {
      enable = true;
      package = pkgs.niri-unstable;
    };
    programs.dms-shell = {
      enable = true;
    };

  };
}
