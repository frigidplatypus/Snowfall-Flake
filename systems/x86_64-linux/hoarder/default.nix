{
  lib,
  modulesPath,
  config,
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
  services.caddy = {
    enable = true;
    virtualHosts = {
      "hoarder.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:3000
          encode gzip
        '';
      };
    };
  };

  sops.secrets.hoarder_env = {
    owner = "karakeep";
  };

  services.karakeep = {
    enable = true;
    environmentFile = config.sops.secrets.hoarder_env.path;
    browser = enabled;
    extraEnvironment = {
      DISABLE_SIGNUPS = "true";
      DISABLE_PASSWORD_AUTH = "false"; # Set to true to force OAuth-only
      DISABLE_NEW_RELEASE_CHECK = "true";
      # OAuth/OIDC Configuration
      OAUTH_WELLKNOWN_URL = "${tsidpUrl}/.well-known/openid-configuration";
      OAUTH_CLIENT_ID = "hoarder";
      OAUTH_SCOPE = "openid profile email"; # Correct: singular OAUTH_SCOPE
      OAUTH_PROVIDER_NAME = "Tailscale";
      # Required base configuration
      NEXTAUTH_URL = "https://${host}.${tailnet}";
    };

  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
