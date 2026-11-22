{
  config,
  lib,
  modulesPath,
  inputs,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
    inputs.telltale.nixosModules.telltale
  ];

  # TelltaleDNS primary: this node owns the shared config (upstreams, clients,
  # records, lists, groups) and serves the tailnet; racknerd is the replica -
  # it serves the last synced snapshot and is the failover target. Declarative
  # join: the bootstrap secret is the same on both nodes, so no interactive
  # `cluster join` token is needed.
  # systemd-resolved's stub (127.0.0.53:53) collides with telltale's default
  # 0.0.0.0:53 listener inside the container; the repo's resolver LXCs (`dns`)
  # kill resolved outright, and tailscale's --accept-dns (frgd tailscale
  # module) owns /etc/resolv.conf. The fork module's `disableResolvedStub`
  # writes the removed `services.resolved.extraConfig` (throws on this
  # nixpkgs) - upstream fix: nixos-module.nix:420.
  services.resolved = disabled;

  # LAN devices off the tailnet query this container's bridge IP, so :53
  # must cross the container firewall on all interfaces. The cluster port
  # (8443, advertised on the tailnet address only) needs no rule: the frgd
  # tailscale module puts tailscale0 in trustedInterfaces. Listeners
  # default to 0.0.0.0/[::]:53; telltale's [access] default admits private
  # ranges, so 192.168.0.x clients get answers. racknerd stays tailnet-only:
  # its listen list is tailscale0 addrs.
  networking.firewall.allowedUDPPorts = [ 53 ];
  networking.firewall.allowedTCPPorts = [
    53
    443 # dashboard vhost (ACME is DNS-01: no inbound 80 needed)
  ];

  services.telltale = {
    enable = true;
    # Svelte dashboard embedded in the binary (nixos-module.nix:77-86:
    # withUi selects `telltale-with-ui`, UI served at / on the api listener;
    # racknerd stays on the UI-less default package).
    withUi = true;

    cluster = {
      enable = true;
      role = "primary";
      name = "frgd";
      site = "telltale";
      # container tailnet IP; stable per node key. Bound + advertised on the
      # tailnet only, so the cluster port never sits on the LXC bridge.
      listenAddress = "100.96.160.59";
      advertise = [ "https://100.96.160.59:8443" ];
      bootstrapSecretFile = config.sops.secrets.telltale_cluster_secret.path;
    };

    # `router` is the fork's tailscale integration: reading tailscaled.sock
    # names every tailnet peer by host name in the UI. One reader is enough -
    # racknerd asks this node for the device names. Upstream hostname URLs
    # carry `bootstrap` (Quad9 direct): the primary is the tailnet resolver,
    # so its own upstream lookups must never walk resolv.conf back into
    # itself. Everything per-node (listen, api, cache, telemetry) stays here;
    # racknerd keeps only its own per-node sections.
    settings = {
      api.listen = "127.0.0.1:8053";

      router = [
        {
          name = "tailnet";
          type = "tailscale";
        }
      ];

      # encrypted upstreams; `fastest` races the group (blocky parallel_best)
      upstream = [
        {
          name = "quad9-tls";
          url = "tls://9.9.9.10:853";
          tls_server_name = "dns.quad9.net";
        }
        {
          name = "quad9-doh";
          url = "https://dns.quad9.net/dns-query";
          bootstrap = [
            "9.9.9.10"
            "149.112.112.10"
          ];
        }
        {
          name = "adguard-quic";
          url = "quic://unfiltered.adguard-dns.com:853";
          tls_server_name = "unfiltered.adguard-dns.com";
          bootstrap = [
            "9.9.9.10"
            "149.112.112.10"
          ];
        }
        {
          name = "adguard-tls";
          url = "tls://unfiltered.adguard-dns.com:853";
          bootstrap = [
            "9.9.9.10"
            "149.112.112.10"
          ];
        }
        {
          name = "adguard-doh";
          url = "https://unfiltered.adguard-dns.com/dns-query";
          bootstrap = [
            "9.9.9.10"
            "149.112.112.10"
          ];
        }
      ];
      upstream_group = [
        {
          name = "default";
          members = [
            "quad9-tls"
            "quad9-doh"
            "adguard-quic"
            "adguard-tls"
            "adguard-doh"
          ];
          strategy = "fastest";
        }
      ];

      cache.max_entries = 1000000;

      # client names only: router (192.168.0.1) rDNS is unreachable from the VPS
      client = [
        {
          name = "actual";
          match = [ "100.68.102.19" ];
        }
        {
          name = "apple-tv";
          match = [ "100.81.214.34" ];
        }
        {
          name = "books";
          match = [ "100.67.104.5" ];
        }
        {
          name = "hass";
          match = [
            "100.112.183.50"
            "192.168.0.14"
          ];
        }
        {
          name = "hoarder";
          match = [ "100.89.252.68" ];
        }
        {
          name = "jPhone";
          match = [ "100.85.219.137" ];
        }
        {
          name = "kitchenixos";
          match = [ "100.88.245.130" ];
        }
        {
          name = "nasnix";
          match = [ "100.93.13.68" ];
        }
        {
          name = "pangolin";
          match = [ "100.88.184.75" ];
        }
        {
          name = "pve";
          match = [ "100.95.160.18" ];
        }
        {
          name = "racknerd";
          match = [ "100.115.4.41" ];
        }
        {
          name = "reader";
          match = [ "100.123.23.115" ];
        }
        {
          name = "recipes";
          match = [ "100.105.13.126" ];
        }
        {
          name = "search";
          match = [ "100.115.169.57" ];
        }
        {
          name = "t480";
          match = [ "100.124.68.25" ];
        }
        {
          name = "tasks";
          match = [ "100.108.249.12" ];
        }
      ];

      # blocky customDNS.mapping -> local records (A/AAAA NODATA for the rest).
      # 192.168.0.x entries only answer on-site, same as before.
      record = [
        {
          name = "ha.frgd.us";
          type = "A";
          value = "192.168.0.14";
        }
        {
          name = "pve.frgd.us";
          type = "A";
          value = "192.168.0.3";
        }
        {
          name = "unifi.frgd.us";
          type = "A";
          value = "192.168.0.14";
        }
        {
          name = "tickets.wc-12.com";
          type = "A";
          value = "100.79.58.16";
        }
        {
          name = "imessage.frgd.us";
          type = "A";
          value = "100.103.184.59";
        }
        {
          name = "dns.frgd.us";
          type = "A";
          value = "100.103.184.59";
        }
        {
          name = "chores.frgd.us";
          type = "A";
          value = "100.103.184.59";
        }
        {
          name = "ha.wc-12.com";
          type = "A";
          value = "100.99.237.24";
        }
        {
          name = "romm.frgd.us";
          type = "A";
          value = "192.168.0.6";
        }
        {
          name = "ollama.frgd.us";
          type = "A";
          value = "100.105.94.91";
        }
        # the dashboard vhost below; this resolver answers it for every
        # tailnet client (public DNS never serves this name to outsiders)
        {
          name = "telltale.frgd.us";
          type = "A";
          value = "100.96.160.59";
        }
      ];

      local.hosts_files = [ "/etc/hosts" ];

      # hosts-format lists only (filter_1 ABP syntax stays dropped, as before)
      list = [
        {
          name = "security-malware";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
        }
        {
          name = "security-urlhaus";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
        }
        {
          name = "security-phish";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
        }
        {
          name = "security-antimalware";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt";
        }
        {
          name = "qwant-api";
          rules = [ "api.qwant.com" ];
        }
        {
          name = "ads-popup";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt";
        }
        {
          name = "ads-hosts";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_4.txt";
        }
        {
          name = "ads-push";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_39.txt";
        }
        {
          name = "ads-smarttv";
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_7.txt";
        }
        # adult-content blocklist (StevenBlack porn-only alternates: ~77k
        # domains, hosts-format) — applies to every group via `default`.
        {
          name = "adult-content";
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts";
        }
        # SearXNG/Searx instances bypass safe search (they query engines with
        # safe_search=off), so they stay blocked: static list + regex catching
        # future instances; refresh command in assets/searxng-instances.txt.
        {
          name = "searxng-instances";
          rules = (lib.splitString "\n" (builtins.readFile ../../../assets/searxng-instances.txt)) ++ [
            "/^searx[a-z0-9.-]+$/"
          ];
        }
      ];

      group = [
        {
          name = "default";
          lists = [
            "security-malware"
            "security-urlhaus"
            "security-phish"
            "security-antimalware"
            "qwant-api"
            "ads-popup"
            "ads-hosts"
            "ads-push"
            "ads-smarttv"
            "adult-content"
            "searxng-instances"
          ];
          # blocky blockType = "refused" / blockTTL 10s (AGH blocking_mode parity)
          block_mode = "refused";
          block_ttl = 10;
          safe_search = true;
        }
      ];

      filter.refresh_secs = 86400; # parity with AGH filters_update_interval
      filter.fetch_timeout_secs = 120;

      telemetry.qlog.retention_days = 90; # parity with AGH querylog interval
    };
  };

  # Dashboard: telltale.frgd.us -> this node's API. ACME DNS-01 through
  # porkbun (frgd.security.acme, same mechanism as recipes/audiobooks) -
  # real trusted certs, unlike *.ts.net names which are MagicDNS-only and
  # leave caddy on its internal CA (browser SSL_ERROR_INTERNAL_ERROR_ALERT).
  # The fork's tailscale router integration runs here (the primary reads
  # tailscaled.sock; replicas ask for the names).
  frgd.services.caddy-proxy = {
    enable = true;
    hosts.telltale = {
      hostname = "telltale.${tailnet}";
      backendAddress = "http://127.0.0.1:8053";
    };
  };

  # cluster bootstrap secret, shared with the racknerd replica
  sops.secrets.telltale_cluster_secret = { };

  frgd.archetypes.lxc = enabled;
}
