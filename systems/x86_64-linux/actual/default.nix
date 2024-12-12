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
    ./docker-compose-actual.nix
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "actual.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:5006
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
