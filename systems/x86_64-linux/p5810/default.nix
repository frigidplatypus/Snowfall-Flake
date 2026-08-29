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
  fonts.packages = with pkgs; [ source-code-pro ];

  services.kmscon = {
    enable = true;
    config = {
      font-name = "Source Code Pro";
      font-size = 14;
      hwaccel = true;
      xkb-layout = "us";
    };
  };

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      registry-mirrors = [ "https://mirror.gcr.io" ];
    };
  };

  environment.systemPackages = with pkgs; [
    herdr
    docker
    nftables
    forgejo-cli
    alacritty
    lswt
    waylevel
    # frgd.numara
    # devede
    # dvdstyler
    # bombono
    ffmpeg_7-full
    # xfce.xfburn
    sleep-on-lan
    nixos-anywhere
    spec-kit
    disko
    nixos-generators
    deploy-rs
    compose2nix
    sanoid
    lzo
    mbuffer
    pv
    devenv
    opencode
    gh
    tg
    nr

    #Ollama TUIs
    gollama

  ];

  environment.sessionVariables = {
    # make sure system helpers are on the PATH seen by login shells
    PATH = "/run/current-system/sw/bin:/run/current-system/profile/bin:/home/justin/.nix-profile/bin";
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  programs.nix-ld.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  # services.vscode-server.enable = true;
  boot.zfs.extraPools = [ "storage" ];

  sops.secrets.open-webui-environment = { };
  sops.secrets.CACHIX_AUTH_TOKEN = {
    owner = "root";
    mode = "0400";
  };

  sops.templates."surface-kernel-cache.env" = {
    owner = config.frgd.user.name;
    mode = "0400";
    content = ''
      CACHIX_AUTH_TOKEN=${config.sops.placeholder.CACHIX_AUTH_TOKEN}
    '';
  };

  systemd.services.surface-kernel-cache = {
    description = "Build Surface kernel cache";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [
      nix
      git
    ];
    serviceConfig = {
      Type = "oneshot";
      User = config.frgd.user.name;
      WorkingDirectory = "/home/${config.frgd.user.name}/flake";
      ExecStart = "${pkgs.bash}/bin/sh /home/${config.frgd.user.name}/flake/scripts/build_surface_kernel_cache.sh --host surface";
      EnvironmentFile = config.sops.templates."surface-kernel-cache.env".path;
    };
    environment = {
      HOME = "/home/${config.frgd.user.name}";
      XDG_CONFIG_HOME = "/home/${config.frgd.user.name}/.config";
    };
  };

  systemd.timers.surface-kernel-cache = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:00:00";
      Persistent = true;
    };
  };

  frgd = {
    nix = {
      enable = true;
    };
    system = {
      boot = {
        enable = true;
        efi = true;
      };
      zfs = enabled;
    };
    services = {
      beszel-agent = enabled;

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
    system.zramSwap = enabled;
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
    };
    suites = {
      common-slim = enabled;
      # desktop = {
      #   enable = true;
      #   gnome = true;
      # };
    };

  };

  users.groups.docker = { };

  frgd.user = {
    extraGroups = [ "docker" ];
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
