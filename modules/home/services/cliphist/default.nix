{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.cliphist;
in
{
  options.frgd.services.cliphist = with types; {
    enable = mkBoolOpt false "Whether or not to enable cliphist.";
  };

  config = mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      systemdTargets = [ "sway-session.target" "default.target" ];
    };
  };
}
