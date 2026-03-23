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
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };
  services.caddy = {
    enable = true;
    virtualHosts = {
      "audiobooks.frgd.us" = {
        extraConfig = ''
          reverse_proxy http://audiobooks.${tailnet}:8000
          encode gzip
        '';
      };
      "recipes.frgd.us" = {
        extraConfig = ''
          reverse_proxy http://recipes.${tailnet}:9000 {
            header_up X-Forwarded-Proto https
          }
          encode gzip
        '';
      };
      "recipes.mar10s.cloud" = {
        extraConfig = ''
          reverse_proxy http://recipes.${tailnet}:9000 {
            header_up X-Forwarded-Proto https
          }
          encode gzip
        '';
      };
    };
  };
  # services.vikunja = {
  #   enable = true;
  #   frontendScheme = "https";
  #   frontendHostname = "tasks.frgd.us";
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
      # mealie = enabled;
      matrix-synapse = disabled;
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
