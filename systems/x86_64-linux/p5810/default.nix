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
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

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
    opencode
    colmena
  ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  programs.nix-ld.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi/";
  services.vscode-server.enable = true;
  boot.zfs.extraPools = [ "storage" ];

  frgd = {
    nix = {
      enable = true;
      github-access-token.enable = true;
    };
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
      zfs-replication = {
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
            "zroot" = "default";
            "zroot/development" = "default";
            "zroot/docker_data" = "default";
            "zroot/home_justin" = "default";
          };
        };
        syncoid = {
          enable = true;
          commands = {
            zroot = {
              source = "zroot";
              target = "root@dads-pve:zroot";
              recursive = true;
            };
            development = {
              source = "zroot/development";
              target = "root@dads-pve:zroot/development";
              recursive = true;
            };
            docker_data = {
              source = "zroot/docker_data";
              target = "root@dads-pve:zroot/docker_data";
              recursive = true;
            };
            home_justin = {
              source = "zroot/home_justin";
              target = "root@dads-pve:zroot/home_justin";
              recursive = true;
            };
          };
        };
      };
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

  # System user for receiving replication via syncoid/ssh
  users.groups.syncoid = { };

  users.users.syncoid = {
    isSystemUser = true;
    description = "Syncoid replication user";
    createHome = false;
    home = "/nonexistent";
    group = "syncoid";
    # Provide a valid shell so remote SSH invocations can run commands (e.g., zfs receive)
    shell = pkgs.bash;
    # Add the SSH public key(s) of the initiator here. Prefer storing them in SOPS.
    # Replace the placeholder below with the real public key for t480's syncoid user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4RssWl8vYZrOaLxKvkU7DhkKem/wGteCEvqNLATyPX syncoid@t480"
    ];
  };

  # Activation script to delegate ZFS permissions to the syncoid user for the datasets
  system.activationScripts.syncoid-zfs-perms.text = ''
    #!/bin/sh
    set -e
    # Only run if zpool command exists
    if ! command -v zpool >/dev/null 2>&1; then
      exit 0
    fi

    # Give the syncoid user delegated ZFS permissions on the relevant datasets
    for ds in zroot zroot/development zroot/docker_data zroot/home_justin; do
      if zfs list "$ds" >/dev/null 2>&1; then
        # grant minimal permissions for receive/send and dataset management
        /sbin/zfs allow syncoid send,receive,mount,create,destroy "$ds" || true
      fi
    done
  '';
}
