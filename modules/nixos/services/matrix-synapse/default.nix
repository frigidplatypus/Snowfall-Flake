{ config, lib, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.matrix-synapse;
  fqdn = "${config.networking.domain}";
  clientConfig."m.homeserver".base_url = "https://frigidplatyp.us";
  serverConfig."m.server" = "frigidplatyp.us:443";
  mkWellKnown = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';
in
{
  options.frgd.services.matrix-synapse = with types; {
    enable = mkBoolOpt false "Whether or not to enable matrix-synapse.";
    fqdn = mkOption {
      type = str;
      example = "example.org";
      description = "The fully qualified domain name of the Matrix homeserver.";
    };

  };

  config = mkIf cfg.enable {
    frgd = {
      security.sops.matrix_registration_shared_secret = enabled;
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    #  services.postgresql.enable = true;
    #  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    #    password = $(cat "${config.age.secrets.postgresql_matrix.path}")
    #    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD '$password';
    #    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
    #      TEMPLATE template0
    #      LC_COLLATE = "C"
    #      LC_CTYPE = "C";
    #  '';

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        # If the A and AAAA DNS records on example.org do not point on the same host as the
        # records for myhostname.example.org, you can easily move the /.well-known
        # virtualHost section of the code to the host that is serving example.org, while
        # the rest stays on myhostname.example.org with no other changes required.
        # This pattern also allows to seamlessly move the homeserver from
        # myhostname.example.org to myotherhost.example.org by only changing the
        # /.well-known redirection target.
        #      "${config.networking.domain}" = {
        #        enableACME = true;
        #        forceSSL = true;
        # This section is not needed if the server_name of matrix-synapse is equal to
        # the domain (i.e. example.org from @foo:example.org) and the federation port
        # is 8448.
        # Further reference can be found in the docs about delegation under
        # https://matrix-org.github.io/synapse/latest/delegate.html
        #        locations."= /.well-known/matrix/server".extraConfig =
        #          mkWellKnown serverConfig;
        # This is usually needed for homeserver discovery (from e.g. other Matrix clients).
        # Further reference can be found in the upstream docs at
        # https://spec.matrix.org/latest/client-server-api/#getwell-knownmatrixclient
        #        locations."= /.well-known/matrix/client".extraConfig =
        #          mkWellKnown clientConfig;
        #      };
        "frigidplatyp.us" = {
          enableACME = true;
          forceSSL = true;
          #        # It's also possible to do a redirect here or something else, this vhost is not
          # needed for Matrix. It's recommended though to *not put* element
          # here, see also the section about Element.
          locations."/".extraConfig = ''
            return 404;
          '';
          # Forward all Matrix API calls to the synapse Matrix homeserver. A trailing slash
          # *must not* be used here.
          locations."/_matrix".proxyPass = "http://[::1]:8008";
          # Forward requests for e.g. SSO and password-resets.
          locations."/_synapse/client".proxyPass = "http://[::1]:8008";
          locations."= /.well-known/matrix/server".extraConfig = mkWellKnown serverConfig;
          locations."= /.well-known/matrix/client".extraConfig = mkWellKnown clientConfig;
        };
      };
    };

    services.matrix-synapse = {
      enable = true;
      settings.server_name = "frigidplatyp.us";
      settings.database.name = "sqlite3";
      settings.listeners = [
        {
          port = 8008;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = true;
            }
          ];
        }
      ];
      extraConfigFiles = [ config.sops.secrets.matrix_registration_shared_secret.path ];
    };

    frgd.security.acme = {
      enable = true;
    };
    security.acme = {
      certs."matrix.frigidplatyp.us" = { };
    };
  };
}
