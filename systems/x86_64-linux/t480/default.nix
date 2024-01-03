{ lib, ... }:
with lib;
with lib.frgd; {
  imports = [ ./hardware.nix ./disko.nix ];

  boot.supportedFilesystems = [ "zfs" ];
  # boot.zfs.forceImportRoot = false;

  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };

    archetypes = { workstation = enabled; };
    desktop = {
      enable = true;
      hyprland = true;
    };

  };
}
