{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.icehouse;
in
{
  options.frgd.tools.icehouse = with types; {
    enable = mkBoolOpt false "Whether or not to enable Icehouse.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.snowfallorg.icehouse ];
  };
}
