# Caddy Proxy Helper Module

This NixOS module provides a declarative interface for creating Caddy reverse-proxy virtual hosts with automatic ACME certificate management for `*.frgd.us` domains and Tailscale integration.

## Options

Located under `frgd.services.caddy-proxy`:

- **`enable`** (bool, default: `false`) - Enable the caddy-proxy helper module
- **`caddyEnvironmentFile`** (string, default: `""`) - Path to Caddy environment file for Tailscale. Leave empty to use sops secret automatically.
- **`hosts`** (attrsOf submodule) - Attribute set of reverse proxy hosts. Each host supports:
  - **`hostname`** (nullOr string, default: `null`) - Public hostname (e.g., `app.frgd.us` or `service.ts.net`)
  - **`tailnetHostname`** (nullOr string, default: `null`) - Alternative tailnet hostname (overrides `hostname` if set)
  - **`backendAddress`** (string, **required**) - Backend address to proxy to (e.g., `http://localhost:3000`)
  - **`useTailnet`** (bool, default: `false`) - Whether this host uses Tailscale (sets up environment file)
  - **`extraConfig`** (string, default: `""`) - Extra Caddyfile config to prepend before `reverse_proxy` directive

## Behavior

- **ACME certificates**: Automatically created for any hostname ending with `.frgd.us`
- **Tailscale integration**: Sets `services.caddy.environmentFile` if any host has `useTailnet = true`
- **Validation**: Asserts that all hosts have a non-empty `backendAddress`
- **Merge-safe**: Uses `lib.mkDefault` so explicit user definitions take priority

## Example

```nix
frgd.services = {
caddy-proxy = {
  enable = true;
  hosts = {
    dns = {
      hostname = "dns.${tailnet}";
      backendAddress = "http://127.0.0.1:3000";
      useTailnet = true;
      extraConfig = "encode gzip";
    };
  };
};
};
```

This will:
- Create `services.caddy.virtualHosts."dns.${tailnet}"` and `services.caddy.virtualHosts."chores.frgd.us"`
- Auto-create `security.acme.certs."chores.frgd.us" = { }` (ACME cert for frgd.us domain)
- Set `services.caddy.environmentFile` for Tailscale (since `dns` uses tailnet)
