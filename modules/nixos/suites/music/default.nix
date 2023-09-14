{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.suites.music;
in
{
  options.frgd.suites.music = with types; {
    enable = mkBoolOpt false "Whether or not to enable music configuration.";
  };

  config = mkIf cfg.enable {
    frgd = {
      apps = {
        ardour = enabled;
        bottles = enabled;
      };
    };
  };
}
