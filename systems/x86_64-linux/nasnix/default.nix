{ lib, pkgs, ... }:
with lib;
with lib.frgd; {
  imports = [ ./hardware.nix ./disko.nix ];

  networking = {
    networkmanager.enable = true;
    hostId = "358bebb3";
    interfaces.eno1.ipv4.addresses = [{
      address = "192.168.0.6";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
    bridges."br0".interfaces = [ "enp1s1" ];
    interfaces."br0".useDHCP = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.extraPools = [ "storage" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = true;

  services = {
    zfs.autoScrub = enabled;
    nfs.server.enable = true;
  };
  networking.firewall.enable = false;
  frgd = {
    security.sops = enabled;
    archetypes.server = enabled;
    services.jellyfin = enabled;
    services = {
      tailscale.autoconnect = enabled;
      netdata = enabled;
      samba = {
        enable = true;
        shares = { ROMS = { path = "/storage/ROMs"; }; };
      };
    };
    virtualization = {
      docker = enabled;
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
