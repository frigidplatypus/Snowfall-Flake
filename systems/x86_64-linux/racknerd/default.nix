{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    inputs.telltale.nixosModules.telltale
    ./hardware.nix
  ];

  # Enable networking
  networking = {
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };

  # TelltaleDNS replica: the `telltale` LXC container owns the shared config
  # (upstreams, clients, records, lists, groups); this node serves the last
  # synced snapshot and is the failover target. Only per-node sections live
  # here (running.md: each node keeps its own [node]/[[listen]]/[cluster]/
  # [api]/[telemetry]). Bound to the tailnet addresses so the public
  # interface never answers DNS; the frgd tailscale module's
  # trustedInterfaces rule already admits :53 from the tailnet.
  # Safe search is native now (group `safe_search = true` on the primary):
  # the forcesafesearch/strict.bing VIP pins and their searxng-denylist
  # guard are gone — the engines' own safe endpoints are used.
  services.telltale = {
    enable = true;
    package = inputs.telltale.packages.${pkgs.stdenv.hostPlatform.system}.default;

    cluster = {
      enable = true;
      role = "replica";
      name = "frgd";
      site = "racknerd";
      # the primary is the telltale container's tailnet address (mTLS, 8443);
      # this node's cluster port stays on tailscale0, never public
      joinUrl = "https://100.96.160.59:8443";
      listenAddress = "100.115.4.41";
      bootstrapSecretFile = config.sops.secrets.telltale_cluster_secret.path;
    };

    # per-node listeners: still answers DNS on the tailnet from the snapshot,
    # and visor.fluffy-rooster.ts.net (caddy-proxy below) keeps serving the
    # cluster UI from here.
    settings = {
      listen = [
        {
          proto = "udp";
          addr = "100.115.4.41:53";
        }
        {
          proto = "tcp";
          addr = "100.115.4.41:53";
        }
        {
          proto = "udp";
          addr = "[fd7a:115c:a1e0::8301:42a]:53";
        }
        {
          proto = "tcp";
          addr = "[fd7a:115c:a1e0::8301:42a]:53";
        }
      ];
      api.listen = "127.0.0.1:8053";
      telemetry.qlog.retention_days = 90; # parity with AGH querylog interval
    };
  };

  # cluster bootstrap secret, shared with the `telltale` primary
  sops.secrets.telltale_cluster_secret = { };

  # listen addresses are tailscale0 assignments; tailscale0 must hold them
  # before telltale binds, and a lost race must retry.
  systemd.services.telltale = {
    after = [ "tailscale.service" ];
    wants = [ "tailscale.service" ];
  };
  services.caddy = {
    enable = true;
    virtualHosts = {
      "audiobooks.frgd.us" = {
        extraConfig = ''
          reverse_proxy http://audiobooks.${tailnet}:8000
          encode gzip
        '';
      };
      "recipes.frgd.us" = {
        extraConfig = ''
          reverse_proxy http://recipes.${tailnet}:9000 {
            header_up X-Forwarded-Proto https
          }
          encode gzip
        '';
      };
      "recipes.mar10s.cloud" = {
        extraConfig = ''
          reverse_proxy http://recipes.${tailnet}:9000 {
            header_up X-Forwarded-Proto https
          }
          encode gzip
        '';
      };
      # "monty.mar10s.cloud" = {
      #   extraConfig = ''
      #     handle_path /notes/* {
      #       respond 404
      #     }
      #     handle_path /vnc/* {
      #       respond 404
      #     }
      #     reverse_proxy https://monty.${tailnet} {
      #       header_up X-Forwarded-Proto https
      #     }
      #     encode gzip
      #   '';
      # };
    };
  };

  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    environment = {
      "SHARE_ALL_SYSTEMS" = "true";
    };
  };

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    settings = {
      server = {
        SSH_PORT = 22;
        SSH_DOMAIN = "git.${tailnet}";
        SSH_LISTEN_PORT = 2222;
        START_SSH_SERVER = true;
        ROOT_URL = "https://git.${tailnet}";
      };
    };
  };

  services.getty.autologinUser = "root";
  services.qemuGuest = enabled;
  frgd = {
    nix = enabled;

    cli-apps = {
      nh = enabled;
    };
    services = {
      openssh = enabled;
      tailscale = enabled;
      # caddy-proxy stays enabled (services.caddy.enable comes from it and
      # the explicit virtualHosts above need caddy running), but the
      # TelltaleDNS dashboard lives on the `telltale` primary now:
      # dns.fluffy-rooster.ts.net. No visor vhost here; this replica runs
      # the UI-less binary and only serves DNS + cluster sync.
      caddy-proxy = {
        enable = true;
      };
      # mealie = enabled;
      matrix-synapse = disabled;
      borgmatic = {
        enable = true;
        autoInit.enable = true;
        directories = [ config.services.forgejo.stateDir ];
        repositories = [ "ssh://dnmk5e0n@dnmk5e0n.repo.borgbase.com/./repo" ];
        notifications.pushover = {
          enable = true;
          apiToken = "aphv2rpofwt7uco51vn672hfkfvagn";
          userKey = "ub1izqc8tz9ps35nhnvt5zznqdsmav";
          onError = true;
        };
      };
    };
    security = {
      sops = enabled;
      doas = enabled;
    };
    system = {
      locale = enabled;
      time = enabled;
      xkb = enabled;
    };
  };
}
