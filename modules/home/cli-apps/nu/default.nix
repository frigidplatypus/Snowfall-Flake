{ lib, config, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.nushell;
in
{
  options.frgd.cli-apps.nushell = with types; {
    enable = mkBoolOpt false "Whether or not to enable nushell.";
  };

  config = mkIf cfg.enable {
    programs.nushell = enabled;
  };
}
