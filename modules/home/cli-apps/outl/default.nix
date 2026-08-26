{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.outl;
in
{
  options.frgd.cli-apps.outl = with types; {
    enable = mkBoolOpt false "Whether to enable outl";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.frgd.outl ];
  };
}
