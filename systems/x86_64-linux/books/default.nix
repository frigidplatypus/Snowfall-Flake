{ lib, ... }:
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
        address = "10.10.4.5";
        prefixLength = 24;
      }
    ];
    defaultGateway = "10.10.4.1";
    nameservers = [ "10.10.4.1" ];
  };
  # services.caddy = {
  #   enable = true;
  #   virtualHosts = {
  #     "books.fluffy-rooster.ts.net" = {
  #       extraConfig = ''
  #         reverse_proxy http://127.0.0.1:8083
  #         encode gzip
  #       '';
  #     };
  #     "books.frgd.us" = {
  #       useACMEHost = "books.frgd.us";
  #       extraConfig = ''
  #         reverse_proxy http://127.0.0.1:8083
  #         encode gzip
  #       '';
  #     };
  #   };
  # };

  frgd = {
    nix = enabled;
    archetypes.server = enabled;
    security.sops = enabled;
    services = {
      syncthing = enabled;
      tailscale = enabled;
      calibre-web = enabled;
    };
    system.boot.efi = true;
  };
}
