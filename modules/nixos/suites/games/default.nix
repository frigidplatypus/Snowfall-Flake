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
  cfg = config.frgd.suites.games;
  apps = {
    #    steam = enabled;
    #lutris = enabled;
  };

in
{
  options.frgd.suites.games = with types; {
    enable = mkBoolOpt false "Whether or not to enable common games configuration.";
  };

  config = mkIf cfg.enable { frgd = { inherit apps; }; };
}
