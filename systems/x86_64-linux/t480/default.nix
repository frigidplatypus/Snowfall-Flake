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
  xdg.portal = enabled;
  services.zram-generator = enabled;
  hardware.xpadneo = enabled;

  environment.systemPackages = with pkgs; [
    lswt
    waylevel
    frgd.numara
    frgd.heynote
    frgd.deploy_select
    frgd.wakeonlan_script
    cifs-utils
    remmina
    nom
    # ventoy-full
    wljoywake
    # cura
    inkscape-with-extensions
    krita
    gimp
    kdePackages.partitionmanager
    kdePackages.ark
    devenv
    gh
    rclone
    nil
    bibletime
    claude-code
    opencode
    vimb
    qutebrowser
  ];

  # services.bibleReadingPlan = {
  #   enable = true;
  #   secretsFile = config.sops.secrets.brp_env.path;
  # };

  # services.bible-reading-plan = {
  #   enable = true;
  #   port = 8080;
  #   adminUsername = "justin";
  #   adminEmail = "jus10mar10@gmail.com";
  #   adminPasswordFile = config.sops.secrets.brp_admin.path;
  # };
  #
  # sops.secrets.brp_admin = {
  #   owner = "bible-reading-plan";
  #   # group = "taskd";
  #   mode = "0440";
  #   #      path = "/home/justin/.taskcerts/taskwarrior_private_key";
  # };

  frgd = {
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
    services = {
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
            "zroot/development" = "default";
            "zroot/home_justin" = "default";
            "zroot/notes" = "default";
          };
        };
        syncoid = {
          enable = true;
          commands = {
            notes = {
              source = "zroot/notes";
              target = "root@p5810:zroot/notes"; # Adjust target as needed for t480
              recursive = true;
            };
            development = {
              source = "zroot/development";
              target = "root@p5810:zroot/development";
              recursive = true;
            };
            home_justin = {
              source = "zroot/home_justin";
              target = "root@p5810:zroot/home_justin";
              recursive = true;
            };
          };
        };
      };
    };
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
