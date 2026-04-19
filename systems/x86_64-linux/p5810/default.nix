{ lib
, pkgs
, config
, inputs
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
  # services.flatpak.enable = true;

  # programs.steam = enabled;
  # xdg.portal = enabled;
  networking.firewall.enable = false;
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
  services.kmscon = {
    enable = true;
    hwRender = true; # Use the GPU for smoother text rendering
    fonts = [
      {
        name = "Source Code Pro";
        package = pkgs.source-code-pro;
      }
    ];
    extraConfig = ''
      xkb-layout=us
      font-size=14
    '';
  };

  virtualisation.docker = {
    # Disable the system-wide Docker daemon when using rootless mode
    enable = false;

    rootless = {
      enable = true;
      setSocketVariable = true;
      # Optionally customize rootless Docker daemon settings
      daemon.settings = {
        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        registry-mirrors = [ "https://mirror.gcr.io" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    docker
    nftables
    slirp4netns
    fuse-overlayfs
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

    #Ollama TUIs
    gollama

  ];

  # Ensure the user session can find the rootless docker socket and helper binaries
  environment.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/docker.sock";
    # make sure system helpers (nft, slirp4netns, fuse-overlayfs) are on the
    # PATH seen by login shells and systemd --user services
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
  services.vscode-server.enable = true;
  boot.zfs.extraPools = [ "storage" ];

  sops.secrets.open-webui-environment = { };

  services.open-webui = {
    enable = true;
    port = 8888;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
    environmentFile = config.sops.secrets.open-webui-environment.path;

  };

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
  };

  services.n8n.enable = true;

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

  # Create a local docker group for rootless dockerd socket ownership and add
  # the primary user to it via the frgd.user.extraGroups option below.
  users.groups.docker = { };

  # Add the docker group to the default user so rootless dockerd can set the
  # socket group without warnings.
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
