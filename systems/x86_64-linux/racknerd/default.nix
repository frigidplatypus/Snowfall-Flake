{ lib, config, ... }:
with lib;
with lib.frgd;
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Enable networking
  networking = {
    networkmanager.enable = true;
  };

  # services.caddy = {
  #   enable = true;
  #   virtualHosts = {
  #     "mealie.fluffy-rooster.ts.net" = {
  #       extraConfig = ''
  #         reverse_proxy http://127.0.0.1:9000
  #         encode gzip
  #       '';
  #     };
  #   };
  # };

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];

  services.getty.autologinUser = "root";
  services.qemuGuest = enabled;
  frgd = {
    nix = enabled;

    cli-apps = {
      nh = enabled;
    };
    services = {
      openssh = enabled;
      tailscale = enabled;
    };
    security = {
      sops = enabled;
      doas = enabled;
    };
    system = {
      locale = enabled;
      time = enabled;
      xkb = enabled;
    };
  };
}
