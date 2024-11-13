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
    interfaces.ens18.ipv4.addresses = [
      {
        address = "10.10.4.8";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.10.4.1";
    nameservers = [ "10.10.4.1" ];
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "unifi.fluffy-rooster.ts.net" = {
        extraConfig = ''
          reverse_proxy https://127.0.0.1:8443 {
            transport http {
              tls
              tls_insecure_skip_verify
            }
          }
          encode gzip
          websocket
          header_up -Authorization
          header_up Host {host}
        '';
      };
    };
  };

  networking.firewall.enable = false;
  frgd = {
    nix = enabled;
    archetypes.vm = enabled;
    services.unifiServer = {
      enable = true;
    };
  };
}
