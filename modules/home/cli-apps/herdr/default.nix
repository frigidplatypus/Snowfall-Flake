{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.herdr;
in
{
  options.frgd.cli-apps.herdr = with types; {
    enable = mkBoolOpt false "Whether to enable herdr (terminal-native agent runtime).";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.herdr ];
  };
}
