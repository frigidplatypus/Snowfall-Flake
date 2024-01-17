{ config, lib, pkgs, ... }:

let
  cfg = config.frgd.tools.icehouse;

  inherit (lib) mkEnableOption mkIf;
in
{
  options.frgd.tools.icehouse = {
    enable = mkEnableOption "Icehouse";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.snowfallorg.icehouse ];
  };
}
