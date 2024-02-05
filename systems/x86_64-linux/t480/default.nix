{ lib, pkgs, ... }:
with lib;
with lib.frgd; {

  imports = [ ./hardware.nix ./disko.nix ];

  # Enable fingerprint reader.
  services.open-fprintd.enable = true;
  services.python-validity.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    wezterm
    alacritty
    lswt
    waylevel
    frgd.numara
  ];
  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };
    apps = {
      element = enabled;
      signal = enabled;
    };
    services = { espanso = enabled; };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    archetypes = { workstation = enabled; };
    virtualization = {
      libvirtd = {
        enable = true;
        virt-manager = enabled;
      };
      docker = enabled;
    };
    suites = {
      desktop = {
        enable = true;
        hyprland = true;
      };
    };
  };
}
