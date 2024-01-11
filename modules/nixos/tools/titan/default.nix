{ options, config, pkgs, lib, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.titan;
in
{
  options.frgd.tools.titan = with types; {
    enable = mkBoolOpt false "Whether or not to install Titan.";
    pkg = mkOpt package pkgs.frgd.titan "The package to install as Titan.";
  };

  config = mkIf cfg.enable {
    frgd.tools = {
      # Titan depends on Node and Git
      node = enabled;
      git = enabled;
    };

    environment.systemPackages = [
      cfg.pkg
    ];
  };
}
