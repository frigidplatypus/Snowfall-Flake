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
    services.tailscale = {
      enable = true;
      autoconnect = enabled;
    };

  };

  services.n8n = {
    enable = true;
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "n8n.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:5678
          encode gzip
        '';
      };
    };
  };

  # Monitoring: Prometheus + node-exporter
  # Minimal configuration: enable prometheus and node-exporter and have Prometheus
  # scrape the local node-exporter on 127.0.0.1:9100. Expand scrapeConfigs as needed
  # to add additional jobs (e.g. caddy metrics, ntfy application metrics).
  services.prometheus = {
    enable = true;
    # Use the package pinned in the flake's pkgs by default; override if needed
    # package = pkgs.prometheus;
    scrapeConfigs = [
      {
        job_name = "node-exporter";
        static_configs = [
          { targets = [ "127.0.0.1:9100" ]; }
        ];
      }
    ];
  };

  # Enable the node exporter via the Prometheus module API (works across
  # pinned nixpkgs versions where `services.node-exporter` may not exist).
  services.prometheus.exporters.node = {
    enable = true;
  };
}
