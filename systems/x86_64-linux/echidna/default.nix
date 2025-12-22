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

  services.blueman.enable = true;

  # Power Management
  services.auto-cpufreq.enable = true;
  # powerManagement.powertop.enable = true;
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
    opencode
    vimb
    qutebrowser
    wtfutil
    github-copilot-cli
    gemini-cli
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
      home-wifi = enabled;
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
    cli-apps = {
      nh.flakePath = "/home/justin/flake";
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

  determinate.enable = true;

  frgd.services = {
    tlp = enabled;
    zfs-replication = {
      enable = true;
      syncoid.sshKey = null;
      syncoid.interval = "hourly";
      datasets = {
        notes = {
          source = "zroot/home_justin/notes";
          target = "syncoid@p5810.fluffy-rooster.ts.net:storage/notes";
        };
        flake = {
          source = "zroot/home_justin/flake";
          target = "syncoid@p5810.fluffy-rooster.ts.net:storage/flake";
        };
        development = {
          source = "zroot/home_justin/development";
          target = "syncoid@p5810.fluffy-rooster.ts.net:storage/development";
        };
        home_justin = {
          source = "zroot/home_justin";
          target = "syncoid@p5810.fluffy-rooster.ts.net:storage/home_justin";
        };
      };
    };
  };

}
