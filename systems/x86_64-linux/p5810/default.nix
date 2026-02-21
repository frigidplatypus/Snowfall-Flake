{
  lib,
  pkgs,
  config,
  inputs,
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
    gh

  ];

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  programs.nix-ld.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
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

      caddy-proxy = {
        enable = true;
        hosts = {
          n8n = {
            hostname = "p5810.${tailnet}:8000";
            backendAddress = "http://127.0.0.1:5678";
            useTailnet = true;
            extraConfig = "encode gzip";
          };
        };
      };
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
            "zroot/var/lib" = "default";
            "zroot/var/lib/libvirt" = "default";
            "zhome/home_justin" = "default";
            "zhome/home_justin/flake" = "default";
            "zhome/home_justin/development" = "default";
            "zhome/home_justin/notes" = "default";
          };
        };
        syncoid = {
          enable = true;
          commands = {
            var_lib = {
              source = "zroot/var/lib";
              target = "root@dads-pve:zroot/var/lib";
              recursive = true;
            };
            libvirt = {
              source = "zroot/var/lib/libvirt";
              target = "root@dads-pve:zroot/var/lib/libvirt";
              recursive = true;
            };
            home_justin = {
              source = "zhome/home_justin";
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
    services.openssh = {
      enable = true;
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
      common-slim = enabled;
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

}
