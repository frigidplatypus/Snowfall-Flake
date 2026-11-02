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

  nixpkgs.overlays = [
    (final: prev: {
      python3Packages = prev.python3Packages.overrideScope (
        pyfinal: pyprev: {
          patool = pyprev.patool.overridePythonAttrs (_: {
            doCheck = false;
          });
        }
      );
      patool = final.python3Packages.patool;
    })
  ];

  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Enable fingerprint reader.
  services.blueman.enable = true;
  hardware.keyboard.qmk.enable = true;
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

  programs.mango = enabled;

  environment.systemPackages = with pkgs; [
    openscad
    # cura-appimage
    popsicle
    # ventoy-full
    inkscape-with-extensions
    devenv
    gh
    rclone
    nil
    mcp-nixos
    wtfutil
    acpi
    powertop
    mattermost-desktop
    remmina
    just
    pnpm
    surface-control
    nautilus
    lutris
    gamescope
    heroic
    gamemode
  ];

  frgd = {
    # Remote desktop — p5810 has no SSH access. Build locally, pull the
    # config from the result symlink.
    nr.command = "build";
    # apps.logseq = enabled;
    nix = {
      enable = true;
      github-access-token = enabled;
      extra-substituters = {
        "https://frgd-surface-kernel.cachix.org" = {
          key = "frgd-surface-kernel.cachix.org-1:pY13n7rTq2oCbPfrE3c45+2Uqfjo9tCQ+eY3NC9k0vo=";
        };
      };
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

    services = {
      zfs-replication = {
        enable = true;
        sanoid = {
          templates = {
            default = {
              hourly = 24;
              daily = 7;
              monthly = 12;
              yearly = 1;
              autosnap = true;
              autoprune = true;
            };
          };
          datasets = {
            "zroot/home_justin" = "default";
          };
        };
        syncoid = {
          enable = true;
          commands = {
            home_justin = {
              source = "zroot/home_justin";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/surface/home_justin";
            };
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
