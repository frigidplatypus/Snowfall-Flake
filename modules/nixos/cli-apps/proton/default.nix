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
  cfg = config.frgd.cli-apps.proton;
in
{
  options.frgd.cli-apps.proton = with types; {
    enable = mkBoolOpt false "Whether or not to enable Proton.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ proton-caller ];
  };
}
