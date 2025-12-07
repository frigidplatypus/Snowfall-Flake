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

  frgd.services.caddy-proxy = {
    enable = true;
    caddyEnvironmentFile = config.sops.secrets.tailscale_caddy_env.path;
    hosts = {
      dns = {
        hostname = "dns.${tailnet}";
        backendAddress = "http://127.0.0.1:3000";
      };

      imessage = {
        hostname = "imessage.frgd.us";
        backendAddress = "http://100.88.184.75:1234";
      };

      chores = {
        hostname = "chores.frgd.us";
        backendAddress = "http://192.168.0.14:2021";
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

  # ACME certs are now created automatically by `services.caddyProxy` for `*.frgd.us` hosts.

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
