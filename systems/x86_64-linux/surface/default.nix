{ lib
, pkgs
, inputs
, config
, ...
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
  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [
    # openscad
    # cura-appimage
    # popsicle
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
    # matterhorn
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

  # frgd.services = {
  #   zfs-replication = {
  #     enable = true;
  #     syncoid.sshKey = null;
  #     syncoid.interval = "hourly";
  #     datasets = {
  #       notes = {
  #         source = "zroot/notes";
  #         target = "syncoid@p5810.fluffy-rooster.ts.net:storage/notes";
  #       };
  #       development = {
  #         source = "zroot/development";
  #         target = "syncoid@p5810.fluffy-rooster.ts.net:storage/development";
  #       };
  #       home_justin = {
  #         source = "zroot/home_justin";
  #         target = "syncoid@p5810.fluffy-rooster.ts.net:storage/home_justin";
  #       };
  #     };
  #   };
  # };

}
