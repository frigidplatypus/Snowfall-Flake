{
  lib,
  config,
  options,
  ...
}:

let
  cfg = config.frgd.services.couchdb;

  inherit (lib) types mkEnableOption mkIf;
in
{
  options.frgd.services.couchdb = with types; {
    enable = mkEnableOption "couchdb";
  };

  config = mkIf cfg.enable {
    services.couchdb = {
      enable = true;
      adminPass = "password";
      extraConfig = ''
        [couchdb]
        single_node=true
        max_document_size = 50000000

        [chttpd]
        require_valid_user = true
        max_http_request_size = 4294967296
        enable_cors = true

        [chttpd_auth]
        require_valid_user = true
        authentication_redirect = /_utils/session.html

        [httpd]
        WWW-Authenticate = Basic realm="couchdb"
        bind_address = 0.0.0.0

        [cors]
        origins = app://obsidian.md, capacitor://localhost, http://localhost
        credentials = true
        headers = accept, authorization, content-type, origin, referer
        methods = GET,PUT,POST,HEAD,DELETE
        max_age = 3600
      '';
    };
    services.nginx.virtualHosts = {
      "obsidian.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:5984";
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
}
