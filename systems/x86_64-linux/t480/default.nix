{ lib, ... }:
with lib;
with lib.frgd; {

  imports = [ ./hardware.nix ./disko.nix ];

  boot.supportedFilesystems = [ "zfs" ];

  # Enable fingerprint reader.
  services.open-fprintd.enable = true;
  services.python-validity.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    archetypes = { workstation = enabled; };
    suites = {
      desktop = {
        enable = true;
        hyprland = true;
      };
    };
  };

}
