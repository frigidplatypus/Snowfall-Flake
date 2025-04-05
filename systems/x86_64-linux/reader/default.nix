{
  lib,
  config,
  modulesPath,
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
  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.sops.secrets.miniflux_password.path;
    config = {
      CLEANUP_FREQUENCY = 48;
      # LISTEN_ADDR = "0.0.0.0:8080";
      BASE_URL = "https://reader.fluffy-rooster.ts.net";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://dns.fluffy-rooster.ts.net/";
      OAUTH2_OIDC_PROVIDER_NAME = "Tailscale";
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_USER_CREATION = "1";
      OAUTH2_REDIRECT_URL="https://reader.fluffy-rooster.ts.net/oauth2/oidc/callback";
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "reader.fluffy-rooster.ts.net" = {
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
