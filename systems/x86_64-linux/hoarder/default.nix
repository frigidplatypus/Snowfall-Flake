{ lib, modulesPath, ... }:
with lib;
with lib.frgd;
{
  imports = [
    ./hoarder-container.nix
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Enable networking
  services.caddy = {
    enable = true;
    virtualHosts = {
      "hoarder.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:3000
          encode gzip
        '';
      };
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
