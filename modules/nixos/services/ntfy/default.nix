{ config, pkgs, lib, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.ntfy;
in {
  options.frgd.services.ntfy = with types; {
    enable = mkBoolOpt false "Whether or not to configure ntfy support.";
    gui = mkBoolOpt false
      "Whether or not to enable a gui to configure ntfy support.";
  };

  config = mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings.base-url = "https://ntfy.frgd.us";
    };
    services.nginx.virtualHosts = {
      "ntfy.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:2586";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;" +
            # required when the server wants to use HTTP Authentication
            "proxy_pass_header Authorization;";
        };
      };
    };
  };
}
