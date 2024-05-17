{ config, lib, ... }:
with lib;
with lib.frgd;
{

  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  networking = {
    useDHCP = false;
    networkmanager.enable = true;
    interfaces.eno1.ipv4.addresses = [
      {
        address = "192.168.0.9";
        prefixLength = 24;
      }
    ];
    bridges."br0".interfaces = [ "enp4s0" ];
    interfaces."br0".useDHCP = true;

    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.1" ];
  };

  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };
    services = {
      # freshrss = enabled;
      espanso = enabled;
      taskserver = enabled;
      ntfy = enabled;
      tailscale.autoconnect = enabled;
      netdata = enabled;
      couchdb = enabled;
      soft-serve = enabled;
      unifiServer = enabled;
      nix-serve = enabled;
    };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
        porkbun = enabled;
      };
    };
    suites = {
      common-slim = enabled;
    };
    virtualization = {
      libvirtd = enabled;
      docker = enabled;
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
      # "reader.frgd.us" = { };
      # "books.frgd.us" = { };
      # "calibre.frgd.us" = { };
      # "books.frgd.us" = { };
      # "notes.frgd.us" = { };
      # "tasks.frgd.us" = { };
      # "recipes.frgd.us" = { };
      # "ha.frgd.us" = { };
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
      "tasks.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8084";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "ag.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://192.168.0.1:81";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "bb.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://100.88.184.75:1234";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "unifi.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "https://192.168.0.14:8443";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "calibre.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "books.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8083";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "notes.frgd.us" = {
        #enableACME = true;
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:3001";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "recipes.frgd.us" = {
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:9927";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "reader.frgd.us" = {
        forceSSL = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8180";
          proxyWebsockets = true; # needed if you need to use WebSocket
          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;"
            +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
        };
      };
      "ha.frgd.us" = {
        forceSSL = true;
        http2 = true;
        useACMEHost = "frgd.us";
        locations."/" = {
          proxyPass = "http://192.168.0.14:8123";
          proxyWebsockets = true; # needed if you need to use WebSocket

          extraConfig =
            # required when the target is also TLS server with multiple hosts
            "proxy_ssl_server_name on;" + "proxy_pass_header Authorization;";
        };
      };
    };
  };
}
