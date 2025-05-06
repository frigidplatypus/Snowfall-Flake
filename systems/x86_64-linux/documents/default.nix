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
      "documents.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:28981
          encode gzip
        '';
      };
    };
  };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets.justin_password;
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
