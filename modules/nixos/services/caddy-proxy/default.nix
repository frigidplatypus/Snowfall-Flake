{ lib, config, ... }:
with lib;
with lib.frgd;
let
  cfg = config.frgd.services.caddy-proxy;
in
{
  options.frgd.services.caddy-proxy = with types; {
    enable = mkBoolOpt false "Enable the caddy-proxy helper to create virtualHosts and ACME certs.";

    caddyEnvironmentFile =
      mkOpt str ""
        "Path to env file for Caddy when using Tailscale. Leave empty to use sops secret.";

    hosts = mkOpt (attrsOf (submodule {
      options = {
        hostname =
          mkOpt (nullOr str) null
            "The public hostname for this reverse proxy (e.g., 'app.frgd.us' or 'service.ts.net').";

        tailnetHostname =
          mkOpt (nullOr str) null
            "Alternative tailnet hostname (overrides hostname if set).";

        backendAddress = mkOpt str "" "Backend address to proxy to (e.g., 'http://localhost:3000').";

        useTailnet = mkBoolOpt false "Whether this host uses Tailscale (sets up environment file).";

        extraConfig =
          mkOpt str ""
            "Extra Caddyfile configuration to prepend before reverse_proxy directive.";
      };
    })) { } "Attribute set of reverse proxy hosts.";
  };

  config = mkIf cfg.enable (
    let
      hosts = cfg.hosts;

      # Use sops secret path as default if caddyEnvironmentFile is empty
      envFile =
        if cfg.caddyEnvironmentFile != "" then
          cfg.caddyEnvironmentFile
        else
          config.sops.secrets.tailscale_caddy_env.path;

      hostList = mapAttrsToList (
        name: h:
        let
          # Determine hostname: tailnetHostname takes priority, then hostname, then attr name
          hostname =
            if h.tailnetHostname != null then
              h.tailnetHostname
            else if h.hostname != null then
              h.hostname
            else
              name;

          # Auto-detect tailnet usage: if hostname contains ".ts.net" or explicit useTailnet is set
          autoUseTailnet = (hasSuffix ".ts.net" hostname) || h.useTailnet;
        in
        {
          inherit name;
          value = {
            inherit hostname;
            backend = h.backendAddress;
            extra = h.extraConfig;
            useTailnet = autoUseTailnet;
          };
        }
      ) hosts;

      vhosts = listToAttrs (
        map (h: {
          name = h.value.hostname;
          value = {
            extraConfig = ''
              encode gzip
              ${optionalString (h.value.extra != "") "${h.value.extra}\n"}reverse_proxy ${h.value.backend}'';
          };
        }) hostList
      );

      # Determine which frgd.us hosts should get ACME cert entries
      frgdHosts = filter (h: hasSuffix ".frgd.us" h.value.hostname) hostList;
      neededCerts = listToAttrs (
        map (h: {
          name = h.value.hostname;
          # Empty attrset - let frgd.security.acme defaults handle configuration
          value = { };
        }) frgdHosts
      );

      anyTailnet = any (h: h.value.useTailnet) hostList;
      anyFrgd = frgdHosts != [ ];

      # Validate all hosts have backendAddress
      invalidHosts = filter (h: h.value.backend == "") hostList;
      hostsValid = invalidHosts == [ ];

    in
    {
      assertions = [
        {
          assertion = hostsValid;
          message = "caddy-proxy: The following hosts are missing backendAddress: ${
            concatStringsSep ", " (map (h: h.name) invalidHosts)
          }";
        }
      ];

      # Enable Caddy web server
      services.caddy.enable = true;

      # Enable ACME if any frgd.us hosts exist
      frgd.security.acme.enable = mkIf anyFrgd true;

      # Add generated virtualHosts (existing user definitions will take priority via mkDefault)
      services.caddy.virtualHosts = mkMerge [
        (mapAttrs (_: mkDefault) vhosts)
      ];

      # If any host uses tailnet, set a default services.caddy.environmentFile (user can override)
      services.caddy.environmentFile = mkIf anyTailnet (mkDefault envFile);

      # Add ACME cert entries for frgd.us hosts (these are empty attrs; user-defined entries elsewhere will merge)
      security.acme.certs = mkMerge [
        (mapAttrs (_: mkDefault) neededCerts)
      ];
    }
  );
}
