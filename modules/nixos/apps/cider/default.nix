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
  cfg = config.frgd.apps.cider;
in
{
  options.frgd.apps.cider = with types; {
    enable = mkBoolOpt false "cider";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      cider
    ];
  };
}
