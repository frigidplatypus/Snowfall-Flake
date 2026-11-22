{
  lib,
  modulesPath,
  config,
  inputs,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    inputs.sparkyfitness.nixosModules.sparkyfitness
  ];

  # SparkyFitness: backend (API, :3010) + local postgres. The module's nginx
  # frontend is disabled; Caddy below serves the static SPA and proxies the
  # API routes on the tailnet instead.
  services.sparkyfitness = {
    enable = true;
    frontendUrl = "https://health.${tailnet}";
    environmentFile = config.sops.secrets.sparkyfitness_env.path;
    nginx.enable = false;
  };

  # systemd reads EnvironmentFile as root; the sops file needs no service owner.
  sops.secrets.sparkyfitness_env = { };

  # Tailnet-facing frontend: static SPA from the frontend package with the
  # same proxy routes the module's nginx config used (api, health-data,
  # uploads, MCP). TLS via the tailnet cert setup (tailscale_caddy_env).
  frgd.services.caddy-proxy = {
    enable = true;
    hosts.health = {
      tailnetHostname = "health.${tailnet}";
      backendAddress = "http://127.0.0.1:${toString config.services.sparkyfitness.port}";
      webRoot = config.services.sparkyfitness.frontendPackage;
      proxyPaths = [
        "/api/*"
        "/health-data"
        "/uploads/*"
        "/mcp"
      ];
    };
  };

  frgd.archetypes.lxc = enabled;
}
