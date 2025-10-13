{
  lib,
  modulesPath,
  pkgs,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Enable networking
  frgd = {
    archetypes.lxc = enabled;
    cli-apps.tmux = enabled;
    security.sops = enabled;
    services = {
      taskchampion = {
        enable = true;
      };
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "tasks.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:10222
          encode gzip
        '';
      };
    };
  };
}
