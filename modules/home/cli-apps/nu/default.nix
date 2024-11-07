{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.frgd) enabled;

  cfg = config.frgd.cli-apps.nushell;
in
{
  options.frgd.cli-apps.nushell = {
    enable = mkEnableOption "nushell";
  };

  config = mkIf cfg.enable {
    programs.nushell = enabled;
  };
}
