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

  # Hermes agent in a systemd-nspawn container.
  # Top-level `containers.<name>` is the nspawn module; `boot.enableContainers`
  # auto-enables when this set is non-empty.
  #
  # The guest is the auto-discovered host `systems/x86_64-linux/hermes`. On
  # first start the host builds its toplevel via `nix build` (nixos-container
  # `update`), so the full flake module set (frgd, hermes-agent, sops-nix) is
  # available to the guest — which the inline `config` path cannot do. `hermes`
  # is excluded from deploy (see lib/deploy/default.nix).
  # --bind=/sops exposes the host age keyfile for activation-time sops decrypt.
  containers.hermes = {
    autoStart = true;
    flake = "/home/justin/flake#hermes";
    privateNetwork = true;
    hostAddress = "10.0.3.1";
    localAddress = "10.0.3.2";
    # No --port forward: the dashboard is reached tailnet-direct (the guest's
    # tailscale0 is a trusted firewall interface, so tailnet clients reach
    # 9119 directly). The veth stays for the guest's outbound NAT only.
    # Guest runs tailscale (archetypes.lxc); needs CAP_NET_ADMIN + /dev/net/tun
    enableTun = true;
    # Hermes Agent Gateway is slow to boot; the 1min default kills the
    # container before the guest signals READY=1 (Type=notify).
    timeoutStartSec = "5min";
    extraFlags = [ "--bind=/sops:/sops" ];
  };

  # Hermes Agent Gateway's shutdown exceeds systemd's 90s default
  # TimeoutStopSec; a stop timeout SIGKILLs nspawn before it cleans up the
  # unix-export mount, so the next spawn refuses ("exists already"). The
  # nixos-containers module only exposes timeoutStartSec, so override the
  # stop timeout directly on the templated unit instance.
  systemd.services."container@hermes".serviceConfig.TimeoutStopSec = "5min";
  # nixos-containers module does not set NAT for --private-network.
  # Without MASQUERADE the guest has no outbound internet. This oneshot
  # is idempotent (C before A) and runs after the veth is up.
  systemd.services."hermes-nat" = {
    description = "MASQUERADE NAT for the hermes container veth";
    after = [
      "network.target"
      "container@hermes.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iptables ];
    script = ''
      iptables -t nat -C POSTROUTING -s 10.0.3.2/32 ! -o ve-hermes -j MASQUERADE \
        || iptables -t nat -A POSTROUTING -s 10.0.3.2/32 ! -o ve-hermes -j MASQUERADE
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # nixos-container.pl does not split `#attr` from the flake ref read from
  # the conf file (only for a CLI `--flake`), so the built-in auto-update
  # builds a double-`#` attr and fails. Root also cannot fetch a local git
  # flake owned by another user (libgit2 error 7). Workaround: oneshot
  # builds the toplevel as justin (repo owner) via runuser, then root sets
  # the container profile. Ordered before container@hermes: the start
  # script finds the profile present and skips the broken auto-update.
  # Rebuilds each boot, so guest flake edits apply on the next reboot.
  systemd.services."hermes-guest-build" = {
    description = "Build the hermes nspawn guest toplevel from the flake";
    wantedBy = [ "machines.target" ];
    after = [ "nix-daemon.service" ];
    before = [ "container@hermes.service" ];
    path = with pkgs; [
      bash
      coreutils
      # nix shells out to git to fetch git flake inputs (go-to-sleep);
      # without it the oneshot dies "executing git: No such file or directory".
      git
      nix
      util-linux
    ];
    script = ''
      set -euo pipefail
      out=$(runuser -u justin -- nix build --print-out-paths \
        '/home/justin/flake#nixosConfigurations."hermes".config.system.build.toplevel')
      mkdir -p /nix/var/nix/profiles/per-container/hermes
      nix-env -p /nix/var/nix/profiles/per-container/hermes/system --set "$out"
    '';
    # nix build drops a `result` symlink in CWD; root's systemd default
    # CWD is /, which justin cannot write. Point it at justin's home.
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/justin";
    };
  };

  environment.systemPackages = with pkgs; [
    # AI coding / terminal CLIs
    omp
    herdr
    concord-tui
    spec-kit
    gollama

    # Git / CI
    act
    gh
    forgejo-cli

    # Nix / deployment
    nixos-anywhere
    disko
    nixos-generators
    deploy-rs
    compose2nix
    devenv
    nr

    # Containers / networking
    docker
    nftables
    tg

    # ZFS / backup plumbing
    sanoid
    lzo
    mbuffer
    pv

    # Wayland / desktop / media
    alacritty
    lswt
    waylevel
    sleep-on-lan
    ffmpeg_7-full

    # Disabled
    # frgd.numara
    # devede
    # dvdstyler
    # bombono
    # xfce.xfburn
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
          # storage minus ROMs; recursive so children are snapshotted too.
          datasets = {
            "storage/photos" = "default";
            "storage/home_justin" = "default";
            "storage/family_share" = "default";
            "storage/development" = "default";
            "storage/notes" = "default";
            "zroot/var/lib" = "default";
          };
        };
        syncoid = {
          enable = true;
          commands = {
            photos = {
              source = "storage/photos";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/p5810/photos";
            };
            home_justin = {
              source = "storage/home_justin";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/p5810/home_justin";
            };
            family_share = {
              source = "storage/family_share";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/p5810/family_share";
            };
            development = {
              source = "storage/development";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/p5810/development";
            };
            notes = {
              source = "storage/notes";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/p5810/notes";
            };
            var_lib = {
              source = "zroot/var/lib";
              target = "root@nasnix.fluffy-rooster.ts.net:storage/backups/p5810/var_lib";
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
