{ lib, pkgs, ... }:
with lib;
with lib.frgd; {
  imports = [ ./hardware.nix ];

  networking = {
    networkmanager.enable = true;
    interfaces.ens18.ipv4.addresses = [{
      address = "192.168.0.31";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
  };
  frgd = {
    archetypes.server.enable = true;
    services = { forgejo = enabled; };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    system.boot.grub = true;
  };
}
