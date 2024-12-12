{ lib, pkgs, ... }:
with lib;
with lib.frgd;
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  # Enable fingerprint reader.
  # services.open-fprintd.enable = true;
  # services.python-validity.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  services.flatpak.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    wezterm
    alacritty
    lswt
    waylevel
    frgd.numara
    cifs-utils
    remmina
    immich-cli
    immich-go
    wl-clipboard
    inkscape
    fontfinder
    frgd.wakeonlan_script
    frgd.numara

  ];
  frgd = {
    nix = enabled;
    system = {
      fonts = {
        enable = true;
      };
      zfs = {
        enable = true;
      };
      boot = {
        enable = true;
        efi = true;
      };
    };
    apps = {
      # element = enabled;
      signal = enabled;
      brave = enabled;
    };
    # services = { espanso = enabled; };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    archetypes = {
      workstation = enabled;
    };
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
        plasma = true;
      };
    };
  };
}
