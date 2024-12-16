{
  lib,
  modulesPath,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "search.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8080
          encode gzip
        '';
      };
    };
  };

  services.searx = {
    enable = true;
    redisCreateLocally = true;
    settings.server = {
      bind_address = "127.0.0.1";
      port = "8080";
      secret_key = "py$3u3^k8a^b=l+dls@z*7qgxdpnv!mksp66@*3n+87i)3qz1y";
      safesearch = true;
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
