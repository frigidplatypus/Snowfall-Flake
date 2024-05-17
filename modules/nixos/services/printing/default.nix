{ config, pkgs, lib, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.printing;
in {
  options.frgd.services.printing = with types; {
    enable = mkBoolOpt false "Whether or not to configure printing support.";
    gui = mkBoolOpt false
      "Whether or not to enable a gui to configure printing support.";
    openFirewall =
      mkBoolOpt false "Whether or not to open firewall for printing";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      openFirewall = (mkIf cfg.openFirewall) true;
      listenAddresses = [ "*:631" ];
    };

    environment.systemPackages = (mkIf cfg.gui) [ pkgs.system-config-printer ];
  };
}
