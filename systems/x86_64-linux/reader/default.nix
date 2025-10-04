{
  lib,
  config,
  modulesPath,
  host ? "",
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Enable networking
  sops.secrets.miniflux_password = {
    mode = "0550";
  };

  # Add OIDC client credentials secret
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets.miniflux_password.path;
    config = {
      CLEANUP_FREQUENCY = 48;
      # LISTEN_ADDR = "0.0.0.0:8080";
      BASE_URL = "https://${host}.${tailnet}";
      # Remove trailing slash to match what the issuer returns
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = tsidpUrl;
      OAUTH2_OIDC_PROVIDER_NAME = "Tailscale";
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_USER_CREATION = "1";
      OAUTH2_REDIRECT_URL = "https://${host}.${tailnet}/oauth2/oidc/callback";
      # Add client credentials (you'll need to set these in your secrets)
      OAUTH2_CLIENT_ID = "tsidp";
      OAUTH2_CLIENT_SECRET = "tsidp";
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "${host}.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:8080
          encode gzip
        '';
      };
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
