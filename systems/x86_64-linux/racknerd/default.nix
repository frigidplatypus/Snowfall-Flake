{ lib, config, ... }:
with lib;
with lib.frgd;
{
  imports = [
    ./hardware.nix
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

  # boot.loader.grub.enable = true;

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
      mealie = enabled;
      matrix-synapse = enabled;
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
