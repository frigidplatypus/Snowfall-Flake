{ lib, ... }:
with lib;
with lib.frgd;
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Enable networking
  networking = {
    networkmanager.enable = true;
    interfaces.enp4s0.ipv4.addresses = [
      {
        address = "10.10.4.5";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.10.4.1";
    nameservers = [ "10.10.4.1" ];
  };
  frgd = {
    archetypes.server = enabled;
    security.sops = enabled;
    services = {
      syncthing = enabled;
      tailscale = enabled;
    };
    system.boot.efi = true;
  };
}
