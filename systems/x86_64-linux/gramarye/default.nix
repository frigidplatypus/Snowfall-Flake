{ lib, ... }:
with lib;
with lib.frgd; {
  imports = [ ./hardware.nix ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking = {
    hostName = "gramarye";
    domain = "frigidplatyp.us";
    networkmanager.enable = true;
  };

  frgd = {
    archetypes.server.enable = true;
    services = {
      matrix-synapse = enabled;
      wireguard-server = { enable = true; };
    };
    security = {
      sops = {
        enable = true;
        # taskwarrior = enabled;
        vultr_api_key = enabled;
        matrix_registration_shared_secret = enabled;
        wireguard_server_key = enabled;
      };
    };
  };
}
