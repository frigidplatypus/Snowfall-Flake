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
  services.flatpak.enable = true;

  programs.steam = enabled;
  xdg.portal = enabled;
  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    wezterm
    alacritty
    lswt
    waylevel
    frgd.numara
    devede
    dvdstyler
    bombono
    ffmpeg_7-full
    xfce.xfburn
    hyprlock
    sleep-on-lan
    nixos-anywhere
    disko
  ];
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  frgd = {
    nix = enabled;
    system = {
      boot = {
        enable = true;
        efi = true;
      };
    };
    apps = {
      element = enabled;
    };
    services = {
      # espanso = enabled;
      esphome = enabled;
      nix-serve = enabled;
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
      common = enabled;
      desktop = {
        enable = true;
        gnome = true;
      };
    };
  };
}
