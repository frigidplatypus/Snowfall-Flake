{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  router = "192.168.0.1";

  # AdGuard Home filter list URLs (hosts-format only).
  # NOTE: filter_1 (AdGuard DNS filter) was intentionally dropped — it uses
  # ABP syntax (||domain^) which blocky cannot parse.
  securityLists = [
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # Malicious URL Blocklist (URLHaus)
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt" # Phishing URL Blocklist (PhishTank + OpenPhish)
    "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt" # Dandelion Sprout's Anti-Malware List
  ];
in
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  environment.systemPackages = with pkgs; [
    systemctl-tui
  ];

  sops.secrets.tailscale_caddy_env = {
    owner = "caddy";
  };

  frgd.services.caddy-proxy = {
    enable = true;
    caddyEnvironmentFile = config.sops.secrets.tailscale_caddy_env.path;
    # NOTE: the old `dns` vhost (AGH web UI backend) is intentionally gone —
    # blocky has no UI. Prometheus metrics stay local on 127.0.0.1:8080 until
    # a scrape solution lands.
    hosts = {
      imessage = {
        hostname = "imessage.frgd.us";
        backendAddress = "http://100.88.184.75:1234";
      };

      chores = {
        hostname = "chores.frgd.us";
        backendAddress = "http://192.168.0.14:2021";
      };
    };
  };

  networking.firewall.enable = false;
  services.resolved = disabled;

  services.blocky = {
    enable = true;

    settings = {
      ports = {
        dns = [ "53" ];
        http = [ "127.0.0.1:8080" ]; # health + DoH + /metrics
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

      clientLookup = {
        upstream = router; # rDNS + PTR, replaces AGH local_ptr_upstreams
        clients = {
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
      };

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
      };

      hostsFile.sources = [ "/etc/hosts" ];

      blocking = {
        denylists = {
          security = securityLists ++ [
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
        };

        clientGroupsBlock.default = [
          "security"
          "ads"
        ];

        blockType = "refused"; # parity with AGH blocking_mode: refused
        blockTTL = "10s"; # parity with AGH blocked_response_ttl

        loading = {
          refreshPeriod = "24h"; # parity with AGH filters_update_interval
          downloads.timeout = "60s";
          strategy = "fast"; # start resolving immediately; lists apply when ready
        };

        # --- Protected-VLAN policy scaffold (fill in later) ---------------
        # 1. Give the `kids` denylist group real content:
        #      blocking.denylists.kids = [ "<adult-list-url>" ... ];
        # 2. Bind the protected VLAN subnet to its groups:
        #      blocking.clientGroupsBlock."10.0.30.0/24" = [ "security" "ads" "kids" ];
        # 3. Force filtered resolution (server-side SafeSearch + adult block)
        #    for that subnet via its own upstream group:
        #      upstreams.groups."10.0.30.0/24" = [
        #        "https://dns-family.adguard.com/dns-query"
        #        "tcp-tls:dns-family.adguard-dns.com"
        #      ];
        # Optional: time-gate any group with blocking.schedules + listSchedules.
        # ------------------------------------------------------------------
      };

      queryLog = {
        type = "sqlite";
        target = "/var/lib/blocky/querylog.db"; # StateDirectory=blocky
        logRetentionDays = 90; # parity with AGH querylog interval 90d
      };
    };
  };

  # Disabled while the old AGH `dns` host is still live: single-use auth key
  # registration would collide at cutover time. Re-enable after retiring dns.
  # services.golink = {
  #   enable = true;
  #   tailscaleAuthKeyFile = config.sops.secrets.golink_tailscale_api_key.path;
  #   verbose = true;
  # };

  services.tsidp = {
    enable = true;
    environmentFile = config.sops.secrets.tailscale_caddy_env.path;
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    security = {
      acme = enabled;
      sops = enabled;
    };
    virtualization.docker = enabled;
  };
}
