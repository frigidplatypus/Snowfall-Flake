{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
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

  # Off-network backup DNS resolver: tailnet clients keep resolving when the
  # home network is down (AGH is LAN-only). Mirrors the `blocky` host config
  # minus LAN-only parts: no Proxmox LXC import, no router rDNS upstream, no
  # caddy-proxy/acme. Bound to the tailnet addresses only (blocky 0.35 has no
  # `interfaces` key — binding is by IP:port), so the public interface never
  # answers DNS; the
  # frgd tailscale module's trustedInterfaces rule already admits :53 from
  # the tailnet, nothing is added to the public firewall.
  services.blocky = {
    enable = true;

    settings = {
      ports = {
        # tailscale0 addresses (stable tailnet assignments for this host)
        dns = [
          "100.115.4.41:53"
          "[fd7a:115c:a1e0::8301:42a]:53"
        ];
        http = [ "127.0.0.1:8080" ]; # health + metrics, loopback only
      };

      prometheus.enable = true;

      bootstrapDns = [
        "9.9.9.10"
        "149.112.112.10"
        "2620:fe::10"
        "2620:fe::fe:10"
      ];

      upstreams = {
        groups.default = [
          "tcp-tls:dns.quad9.net"
          "https://dns.quad9.net/dns-query"
          "quic:unfiltered.adguard-dns.com"
          "tcp-tls:unfiltered.adguard-dns.com"
          "https://unfiltered.adguard-dns.com/dns-query"
        ];
        strategy = "parallel_best";
        timeout = "10s";
      };

      caching.maxItemsCount = 1000000;

      # Client names only: router (192.168.0.1) rDNS is unreachable from the VPS.
      clientLookup.clients = {
        actual = [ "100.68.102.19" ];
        apple-tv = [ "100.81.214.34" ];
        books = [ "100.67.104.5" ];
        hass = [
          "100.112.183.50"
          "192.168.0.14"
        ];
        hoarder = [ "100.89.252.68" ];
        jPhone = [ "100.85.219.137" ];
        kitchenixos = [ "100.88.245.130" ];
        nasnix = [ "100.93.13.68" ];
        pangolin = [ "100.88.184.75" ];
        pve = [ "100.95.160.18" ];
        racknerd = [ "100.115.4.41" ];
        reader = [ "100.123.23.115" ];
        recipes = [ "100.105.13.126" ];
        search = [ "100.115.169.57" ];
        t480 = [ "100.124.68.25" ];
        tasks = [ "100.108.249.12" ];
      };

      # Same mappings as AGH/LAN blocky; 192.168.0.x entries only help on-site.
      customDNS.mapping = {
        "ha.frgd.us" = "192.168.0.14";
        "pve.frgd.us" = "192.168.0.3";
        "unifi.frgd.us" = "192.168.0.14";
        "tickets.wc-12.com" = "100.79.58.16";
        "imessage.frgd.us" = "100.103.184.59";
        "dns.frgd.us" = "100.103.184.59";
        "chores.frgd.us" = "100.103.184.59";
        "ha.wc-12.com" = "100.99.237.24";
        "romm.frgd.us" = "192.168.0.6";
        "ollama.frgd.us" = "100.105.94.91";

        # Safe-search enforcement (ISP redirect technique): pin search hosts
        # to the provider's safe-search VIP. A-only — AAAA returns NODATA,
        # clients fall back to IPv4. Keys match domain + subdomains, so Google
        # keys are host-specific: a `google.com` key would catch
        # mail/drive/accounts and break them (VIP serves search only).
        # Bing edge IPs rotate; refresh from `host strict.bing.com` if Bing
        # search starts erroring. DuckDuckGo pin is Azure-backed, can change.
        # YouTube/Yahoo have none (verified NXDOMAIN, 2026-10). Brave/Qwant
        # endpoints exist but serve unfiltered results anyway (verified live);
        # Startpage's safe host refuses connections. Not DNS-enforceable.
        "www.google.com" = "216.239.38.120"; # forcesafesearch.google.com
        "images.google.com" = "216.239.38.120";
        "www.bing.com" = "150.171.28.16,150.171.27.16"; # strict.bing.com edge
        "images.bing.com" = "150.171.28.16,150.171.27.16"; # 301 via strict edge
        "video.bing.com" = "150.171.28.16,150.171.27.16";
        "duckduckgo.com" = "40.89.244.237"; # safe.duckduckgo.com
      };

      hostsFile.sources = [ "/etc/hosts" ];

      blocking = {
        denylists = {
          # Hosts-format lists only; filter_1 (ABP syntax) intentionally dropped.
          security = [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # Malicious URL Blocklist (URLHaus)
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Phishing URL Blocklist (PhishTank + OpenPhish)
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt" # Dandelion Sprout's Anti-Malware List
            # carried over from AGH user_rules: ||api.qwant.com^$important
            ''
              api.qwant.com
            ''
          ];
          ads = [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt" # AdGuard DNS Popup Hosts filter
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt" # Dan Pollock's List
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt" # Dandelion Sprout's Anti Push Notifications
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt" # Perflyst + Dandelion Sprout's Smart-TV Blocklist
          ];
          # SearXNG/Searx instances: unfiltered metasearch proxies that
          # bypass the SafeSearch pins above (they query Google/Bing with
          # safe_search=off). Static list + regex catching future instances;
          # refresh command in assets/searxng-instances.txt header.
          searxng = [
            # trailing regex catches future searx*/searxng.* instances; blocky
            # only parses an entry as inline content when it contains newlines,
            # so it must ride inside the readFile string.
            ((builtins.readFile ../../../assets/searxng-instances.txt) + "\n/^searx[a-z0-9.-]+$/\n")
          ];
        };

        clientGroupsBlock.default = [
          "security"
          "ads"
          "searxng"
        ];

        blockType = "refused"; # parity with AGH blocking_mode: refused
        blockTTL = "10s"; # parity with AGH blocked_response_ttl

        loading = {
          refreshPeriod = "24h"; # parity with AGH filters_update_interval
          downloads.timeout = "60s";
          strategy = "fast"; # start resolving immediately; lists apply when ready
        };
      };

      queryLog = {
        type = "sqlite";
        target = "/var/lib/blocky/querylog.db"; # StateDirectory=blocky
        logRetentionDays = 90; # parity with AGH querylog interval 90d
      };
    };
  };

  # interface-address binding happens at startup; tailscale0 must hold its
  # address first, and a lost race must retry.
  systemd.services.blocky = {
    after = [ "tailscale.service" ];
    wants = [ "tailscale.service" ];
    serviceConfig.Restart = "on-failure";
    serviceConfig.RestartSec = "5s";
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
      "monty.mar10s.cloud" = {
        extraConfig = ''
          handle_path /notes/* {
            respond 404
          }
          handle_path /vnc/* {
            respond 404
          }
          reverse_proxy https://monty.${tailnet} {
            header_up X-Forwarded-Proto https
          }
          encode gzip
        '';
      };
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
