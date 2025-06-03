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
      "brp.${tailnet}" = {
        extraConfig =
          #Caddyfile
          ''
            reverse_proxy http://127.0.0.1:8000
            encode gzip
          '';
      };
    };
  };
  services.bible-reading-plan = {
    enable = true;
    adminUsername = "justin";
    adminEmail = "jus10mar10@gmail.com";
    adminPasswordFile = config.sops.secrets.brp_admin.path;
  };
  sops.secrets.brp_admin = {
    owner = "bible-reading-plan";
    # group = "taskd";
    mode = "0440";
    #      path = "/home/justin/.taskcerts/taskwarrior_private_key";
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
