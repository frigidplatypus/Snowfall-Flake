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
    openscad
    wezterm
    alacritty
    lswt
    waylevel
    frgd.numara
    cifs-utils
    remmina
    wl-clipboard
    inkscape
    frgd.wakeonlan_script
    frgd.numara
    # stable-pkgs.cura
    # slic3r
    # super-slicer
    cura-appimage
    libation
    devenv
    localsend
    jocalsend

  ];
  frgd = {
    nix = enabled;
    system = {
      fonts = {
        enable = true;
      };
      #zfs = {
      #  enable = true;
      #};
      boot = {
        enable = true;
        efi = true;
      };
    };
    apps = {
      # element = enabled;
      signal = enabled;
      steam = enabled;
    };
    security = {
      sops = {
        enable = true;
      };
    };
    archetypes = {
      workstation = enabled;
    };
    suites = {
      desktop = {
        enable = true;
        # cosmic = true;
        gnome = true;
      };
    };
  };
}
