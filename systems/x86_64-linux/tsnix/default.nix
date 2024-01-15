{ lib, pkgs, ... }:
with lib;
with lib.frgd; {

  imports = [ ./hardware.nix ./disko.nix ];

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    interfaces.eno1.ipv4.addresses = [{
      address = "192.168.0.9";
      prefixLength = 24;
    }];
    bridges."br0".interfaces = [ "enp4s0" ];
    interfaces."br0".useDHCP = true;

    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
  };

  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };
    services = {
      espanso = enabled;
      tailscale.autoconnect = enabled;
    };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    suites = { common-slim = enabled; };
    virtualization = { libvirtd = enabled; };
  };
}
