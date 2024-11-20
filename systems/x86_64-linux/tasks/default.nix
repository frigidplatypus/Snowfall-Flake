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
    interfaces.ens18.ipv4.addresses = [
      {
        address = "10.10.4.6";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.10.4.1";
    nameservers = [ "10.10.4.1" ];
  };

  frgd = {
    archetypes.vm = enabled;
    nix = enabled;
    services = {
      taskchampion = {
        enable = true;
      };
    };
    virtualization.docker = enabled;
  };
}
