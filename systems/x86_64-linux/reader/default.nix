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
        address = "10.10.4.7";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.10.4.1";
    nameservers = [ "10.10.4.1" ];
  };
  sops.secrets.miniflux_password = {
    mode = "0550";
  };
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets.miniflux_password.path;
    config = {
      CLEANUP_FREQUENCY = 48;
      # LISTEN_ADDR = "0.0.0.0:8080";
      BASE_URL = "https://reader.fluffy-rooster.ts.net";
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "reader.fluffy-rooster.ts.net" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8080
          encode gzip
        '';
      };
    };
  };

  frgd = {
    nix = enabled;
    archetypes.vm = enabled;
    services = {
      calibre-web = enabled;
    };
  };
}
