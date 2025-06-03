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
    wezterm
    alacritty
    lswt
    waylevel
    frgd.numara
    frgd.heynote
    frgd.deploy_select
    frgd.wakeonlan_script
    cifs-utils
    remmina
    go
    nom
    ventoy-full
    wljoywake
    # cura
    inkscape-with-extensions
    krita
    gimp
    # mypaint
    inputs.ghostty.packages.x86_64-linux.default
    gparted
    kdePackages.partitionmanager
    kdePackages.ark
    devenv
    gh
  ];

  # services.bibleReadingPlan = {
  #   enable = true;
  #   secretsFile = config.sops.secrets.brp_env.path;
  # };

  services.bible-reading-plan = {
    enable = true;
    adminUsername = "justin";
    adminEmail = "jus10mar10@gmail.com";
    adminPasswordFile = config.sops.secrets.brp_admin.path;
  };
  sops.secrets.brp_admin = {
    owner = "bible-reading-plan";
    # group = "taskd";
    mode = "0440";
    #      path = "/home/justin/.taskcerts/taskwarrior_private_key";
  };

  frgd = {
    nix = enabled;
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
    #services = { espanso = enabled; };
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
