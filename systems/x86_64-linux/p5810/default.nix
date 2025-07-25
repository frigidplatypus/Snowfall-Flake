{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.frgd;
{

  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Enable fingerprint reader.
  services.blueman.enable = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true;
  # services.flatpak.enable = true;

  # programs.steam = enabled;
  # xdg.portal = enabled;
  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    alacritty
    lswt
    waylevel
    # frgd.numara
    frgd.deploy_select
    # devede
    # dvdstyler
    # bombono
    ffmpeg_7-full
    # xfce.xfburn
    sleep-on-lan
    nixos-anywhere
    disko
    deploy-rs
    nixos-generators
    compose2nix
    sanoid
    lzo
    mbuffer
    pv
    devenv
  ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  programs.nix-ld.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi/";

  frgd = {
    nix = enabled;
    system = {
      boot = {
        enable = true;
        efi = true;
      };
      zfs = enabled;
    };
    apps = {
      element = enabled;
    };
    services = {
      # espanso = enabled;
      # esphome = enabled;
      samba = {
        enable = true;
        shares = {
          ROMS = {
            path = "/storage/ROMs";
            public = true;
          };
        };
      };
    };
    security = {
      sops = {
        enable = true;
      };
    };
    archetypes = {
      # workstation = enabled;
    };
    virtualization = {
      libvirtd = {
        enable = true;
        virt-manager = enabled;
      };
      docker = enabled;
    };
    suites = {
      common = enabled;
      # desktop = {
      #   enable = true;
      #   gnome = true;
      # };
    };
  };
}
