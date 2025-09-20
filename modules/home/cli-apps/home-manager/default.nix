{ lib, config, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.home-manager;
in
{
  options.frgd.cli-apps.home-manager = with types; {
    enable = mkBoolOpt false "Whether or not to enable home-manager.";
  };

  config = mkIf cfg.enable {
    programs.home-manager = enabled;
  };
}
