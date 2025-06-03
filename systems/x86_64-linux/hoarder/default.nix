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
    # ./hoarder-container.nix
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

  sops.secrets.hoarder_env = {
    owner = "karakeep";
  };

  services.karakeep = {
    enable = true;
    environmentFile = config.sops.secrets.hoarder_env.path;

  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
