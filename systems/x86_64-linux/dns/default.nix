{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  environment.systemPackages = with pkgs; [
    systemctl-tui
  ];

  sops.secrets.tailscale_caddy_env = {
    owner = "caddy";
  };

  services.caddy = {
    enable = true;
    environmentFile = config.sops.secrets.tailscale_caddy_env.path;
    virtualHosts = {
      "dns.${tailnet}" = {
        extraConfig =
          #Caddyfile
          ''
            reverse_proxy http://127.0.0.1:3000
            encode gzip
          '';
      };
      "imessage.frgd.us" = {
        useACMEHost = "imessage.frgd.us";
        extraConfig =
          #Caddyfile
          ''
            reverse_proxy http://100.88.184.75:1234
            encode gzip
          '';
      };
      "chores.frgd.us" = {
        useACMEHost = "chores.frgd.us";
        extraConfig =
          #Caddyfile
          ''
            reverse_proxy http://192.168.0.14:2021
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

  security.acme.certs."imessage.frgd.us" = { };
  security.acme.certs."chores.frgd.us" = { };
  security.acme.certs."dns.frgd.us" = { };

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
    security = {
      acme = enabled;
      sops = enabled;
    };
    # services.netalertx = enabled;
    virtualization.docker = enabled;
  };
}
