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
  networking.firewall.enable = false;

  services.caddy = {
    enable = true;
    virtualHosts = {
      "ai.${tailnet}" = {
        extraConfig = ''
          reverse_proxy https://127.0.0.1:8000
          encode gzip
        '';
      };
    };
  };

  services.open-webui = {
    enable = true;
    port = 8888;
    host = "0.0.0.0";
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
