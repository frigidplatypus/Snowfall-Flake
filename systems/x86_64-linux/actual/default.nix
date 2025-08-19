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
    # ./docker-compose-actual.nix
  ];
  services.caddy = {
    enable = true;
    virtualHosts = {
      "actual.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:3000
          encode gzip
        '';
      };
    };
  };

  services.actual = {
    enable = true;
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
