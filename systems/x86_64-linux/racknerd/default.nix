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
  security.acme = {
    certs."audiobooks.frgd.us" = { };
  };
  services.nginx = {
    virtualHosts."audiobooks.frgd.us" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://audiobooks.fluffy-rooster.ts.net:8000";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };
  };

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
