{ lib
, pkgs
, config
, ...
}:
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

  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
  };

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    settings = {
      server = {
        SSH_PORT = 22;
        SSH_DOMAIN = "git.${tailnet}";
        SSH_LISTEN_PORT = 2222;
        START_SSH_SERVER = true;
        ROOT_URL = "https://git.${tailnet}";
      };
    };
  };

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
