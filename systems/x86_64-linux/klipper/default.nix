{ lib, pkgs, ... }:
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
  };
  networking.firewall.enable = false;
  frgd = {
    nix = enabled;
    archetypes.server = enabled;
    security.sops = enabled;
    services = {
      syncthing = enabled;
      klipper = enabled;
    };
    system.boot.efi = true;
    system.boot.oldBoot = true;
    user.extraGroups = [ "moonraker" ];
  };
}
