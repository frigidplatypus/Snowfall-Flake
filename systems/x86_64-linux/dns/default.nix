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
      "dns.${tailnet}:8000" = {
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

  sops.secrets.golink_tailscale_api_key = {
    owner = "golink";
  };

  # Enable networking
  services.golink = {
    enable = true;
    tailscaleAuthKeyFile = config.sops.secrets.golink_tailscale_api_key.path;
    verbose = true;
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    services.tsidp = enabled;
    # services.netalertx = enabled;
    virtualization.docker = enabled;
  };
}
