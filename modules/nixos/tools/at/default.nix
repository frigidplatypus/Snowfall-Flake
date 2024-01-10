{ options, config, pkgs, lib, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.at;
in
{
  options.frgd.tools.at = with types; {
    enable = mkBoolOpt false "Whether or not to install at.";
    pkg = mkOpt package pkgs.frgd.at "The package to install as at.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.pkg
    ];
  };
}
