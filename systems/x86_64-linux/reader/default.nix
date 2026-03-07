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

  # Admin credentials secret (moved from module)

  # Add OIDC client credentials secret and Miniflux service settings
  services.miniflux = {
    enable = true;
    # keep existing admin credentials file reference for compatibility
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

  # Additional configuration moved from the miniflux module
  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    security = {
      sops = {
        enable = true;
        porkbun = enabled;
      };
    };
  };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults = {
  #     email = "jus10mar10@gmail.com";
  #     dnsProvider = "porkbun";
  #     environmentFile = config.sops.secrets.porkbun_api_key.path;
  #     group = "nginx";
  #   };
  #   certs = {
  #     "frgd.us" = {
  #       extraDomainNames = [ "*.frgd.us" ];
  #     };
  #   };
  # };

  # services.nginx = {
  #   enable = true;
  #   recommendedProxySettings = true;
  #   recommendedTlsSettings = true;
  #   virtualHosts = {
  #     "miniflux" = {
  #       #enableACME = true;
  #       forceSSL = true;
  #       useACMEHost = "frgd.us";
  #       locations."/" = {
  #         proxyPass = "http://127.0.0.1:8088";
  #         proxyWebsockets = true;
  #         extraConfig = "proxy_ssl_server_name on;" + "proxy_pass_header Authorization;";
  #       };
  #     };
  #   };
  # };

  # Explicitly disable nginx so only Caddy binds 80/443.
  services.nginx = {
    enable = false;
  };

  # Disable Caddy here to avoid binding conflicts with nginx (both wanted 80/443).
  # If you prefer Caddy as the public proxy, enable it and disable nginx instead.
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
}
