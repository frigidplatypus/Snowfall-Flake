{ lib, pkgs, ... }:
with lib;
with lib.frgd; {
  imports = [ ./hardware.nix ];

  networking = {
    networkmanager.enable = true;
    hostId = "358bebb3";
    interfaces.eno1.ipv4.addresses = [{
      address = "192.168.0.6";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services = {
    zfs.autoScrub = enabled;
    nfs.server.enable = true;
  };
  networking.firewall.enable = false;
  frgd = {
    archetypes.server = enabled;
    services.jellyfin = enabled;
    virtualization = {
      # docker = enabled;
      libvirtd = enabled;
    };
    system = {
      zfs = {
        enable = true;
        pools = [ "storage" ];
        auto-snapshot = enabled;
      };
    };
  };
}
