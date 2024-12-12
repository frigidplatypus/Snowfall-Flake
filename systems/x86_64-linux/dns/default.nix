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
        extraConfig = ''
          reverse_proxy http://127.0.0.1:5380
          encode gzip
        '';
      };
    };
  };
  services = {
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
      firewallTCPPorts = [
        53
        5380
        53443
        443
        853
        80
      ];
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
