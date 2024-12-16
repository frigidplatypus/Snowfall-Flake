{ lib, pkgs, ... }:
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
  services.flatpak.enable = true;
  xdg.portal = enabled;
  services.zram-generator = enabled;
  hardware.xpadneo = enabled;

  environment.systemPackages = with pkgs; [
    wezterm
    alacritty
    lswt
    waylevel
    frgd.numara
    frgd.heynote
    frgd.deploy_select
    frgd.wakeonlan_script
    cifs-utils
    remmina
    go
    nom
    ventoy-full
    wljoywake
    # cura
    inkscape-with-extensions
    krita
    gimp
    # mypaint
  ];
  frgd = {
    nix = enabled;
    system = {
      boot = {
        enable = true;
        efi = true;
      };
      fonts = {
        enable = true;
        fontpreview = true;
      };
    };
    # hardware = {
    #   fingerprint = {
    #     enable = true;
    #     t480 = true;
    #   };
    # };
    apps = {
      # element = disabled;
      signal = enabled;
      steam = enabled;
    };
    #services = { espanso = enabled; };
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
        hyprland = true;
      };
    };
    tools = {
      mdpdf = enabled;
      misc = enabled;
    };
  };
}
