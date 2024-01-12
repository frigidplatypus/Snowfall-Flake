{ lib, pkgs, ... }:
with lib;
with lib.frgd; {

  imports = [ ./hardware.nix ];

  # Enable fingerprint reader.
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  services.flatpak.enable = true;

  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };
    services = { espanso = enabled; };
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
