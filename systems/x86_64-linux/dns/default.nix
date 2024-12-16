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
      "dns.${tailnet}" = {
        extraConfig =
          #Caddyfile
          ''
            reverse_proxy http://127.0.0.1:3000
            encode gzip
          '';
      };
    };
  };
  networking.firewall.enable = false;
  services.resolved = disabled;
  services = {
    adguardhome = {
      enable = true;
      mutableSettings = true;
      allowDHCP = true;
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
