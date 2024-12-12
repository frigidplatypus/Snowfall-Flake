{ lib, modulesPath, ... }:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "recipes.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:9000
          encode gzip
        '';
      };
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    services = {
      mealie = {
        enable = true;
      };
    };
  };
}
