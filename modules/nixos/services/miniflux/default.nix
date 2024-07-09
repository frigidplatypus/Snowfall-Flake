{
  # options,
  config,
  lib,
  # pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.miniflux;
in
{
  options.frgd.services.miniflux = with types; {
    enable = mkBoolOpt false "Whether or not to enable miniflux.";
  };

  config = mkIf cfg.enable {

    sops.secrets.miniflux_admin_file = { };

    services.miniflux = {
      enable = true;
      adminCredentialsFile = config.sops.secrets.miniflux_admin_file.path;
      config = {
        LISTEN_ADDR = "0.0.0.0:8088";
        # BASE_URL = "http://miniflux";
      };
    };
    frgd = {
      security = {
        sops = {
          enable = true;
          porkbun = enabled;
        };
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "jus10mar10@gmail.com";
        dnsProvider = "porkbun";
        environmentFile = config.sops.secrets.porkbun_api_key.path;
        group = "nginx";
      };
      certs = {
        "frgd.us" = {
          extraDomainNames = [ "*.frgd.us" ];
        };
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      # other Nginx options
      virtualHosts = {
        "miniflux" = {
          #enableACME = true;
          forceSSL = true;
          useACMEHost = "frgd.us";
          locations."/" = {
            proxyPass = "http://127.0.0.1:8088";
            proxyWebsockets = true; # needed if you need to use WebSocket
            extraConfig =
              # required when the target is also TLS server with multiple hosts
              "proxy_ssl_server_name on;"
              +
                # required when the server wants to use HTTP Authentication
                "proxy_pass_header Authorization;";
          };
        };
      };
    };
  };
}
