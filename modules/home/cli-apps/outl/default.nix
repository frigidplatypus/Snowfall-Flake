{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.outl;
  outl = inputs.outl.packages.${pkgs.system}.outl;
in
{
  options.frgd.cli-apps.outl = with types; {
    enable = mkBoolOpt false "Whether to enable outl";
  };

  config = mkIf cfg.enable {
    home.packages = [ outl ];
  };
}
