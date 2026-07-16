{
  lib,
  pkgs,
  inputs,
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
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.zram-generator = enabled;
  hardware.xpadneo = enabled;
  boot.zfs.forceImportRoot = true;
  fonts.fontconfig.enable = true;
  services.upower = enabled;
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq.enable = true;
  powerManagement = {
    powertop.enable = true;
    # Noctalia v5 does not handle PrepareForSleep(true); lock via logind before sleep.
    powerDownCommands = "${pkgs.systemd}/bin/loginctl lock-sessions";
  };

  environment.systemPackages = with pkgs; [
    openscad
    # cura-appimage
    popsicle
    # ventoy-full
    inkscape-with-extensions
    krita
    gimp
    devenv
    gh
    rclone
    nil
    bibletime
    opencode
    wtfutil
    godot
    acpi
    powertop
    mattermost-desktop
    remmina
    just
    # matterhorn

    # android
    androidsdk
    android-cli
    android-tools
    android-studio
    pnpm
    surface-control
    nautilus
    lutris
    frgd.silverbullet-desktop
    gamescope
  ];

  frgd = {
    # apps.logseq = enabled;
    nix = {
      enable = true;
      github-access-token = enabled;
    };
    system = {
      boot = {
        enable = true;
        efi = true;
      };
      zramSwap = enabled;
      zfs = enabled;
      fonts = {
        enable = true;
        fontpreview = true;
      };
    };
    apps = {
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
    # virtualization = {
    #   libvirtd = {
    #     enable = true;
    #     virt-manager = enabled;
    #   };
    #   docker = enabled;
    # };
    suites = {
      desktop = {
        enable = true;
        niri = true;
      };
    };
    tools = {
      mdpdf = enabled;
      misc = enabled;
    };
  };

}
