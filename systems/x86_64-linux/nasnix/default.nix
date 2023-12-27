{ lib, pkgs, ... }:
with lib;
with lib.frgd; {
  imports = [ ./hardware.nix ./disko.nix ];

  networking = {
    networkmanager.enable = true;
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.0.6";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
  };
  frgd = {
    archetypes.server.enable = true;
    security = {
      agenix = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    system.boot.efi = true;
  };
}
