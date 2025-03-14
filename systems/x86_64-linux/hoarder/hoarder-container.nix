# Auto-generated using compose2nix v0.3.1.
{
  pkgs,
  lib,
  config,
  ...
}:

{
  # Runtime
  sops.secrets.hoarder_env = {
  };
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
    defaultNetwork.settings = {
      # Required for container networking to be able to use names.
      dns_enabled = true;
    };
  };

  # Enable container name DNS for non-default Podman networks.
  # https://github.com/NixOS/nixpkgs/issues/226365
  networking.firewall.interfaces."podman+".allowedUDPPorts = [ 53 ];

  virtualisation.oci-containers.backend = "podman";

  # Containers
  virtualisation.oci-containers.containers."hoarder-chrome" = {
    image = "gcr.io/zenika-hub/alpine-chrome:123";
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    cmd = [
      "--no-sandbox"
      "--disable-gpu"
      "--disable-dev-shm-usage"
      "--remote-debugging-address=0.0.0.0"
      "--remote-debugging-port=9222"
      "--hide-scrollbars"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=chrome"
      "--network=hoarder_default"
    ];
  };
  systemd.services."podman-hoarder-chrome" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-hoarder_default.service"
    ];
    requires = [
      "podman-network-hoarder_default.service"
    ];
    partOf = [
      "podman-compose-hoarder-root.target"
    ];
    wantedBy = [
      "podman-compose-hoarder-root.target"
    ];
  };
  virtualisation.oci-containers.containers."hoarder-meilisearch" = {
    image = "docker.io/getmeili/meilisearch:v1.11.1";
    environmentFiles = [ config.sops.secrets.hoarder_env.path ];
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    volumes = [
      "hoarder_meilisearch:/meili_data:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=meilisearch"
      "--network=hoarder_default"
    ];
  };
  systemd.services."podman-hoarder-meilisearch" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-hoarder_default.service"
      "podman-volume-hoarder_meilisearch.service"
    ];
    requires = [
      "podman-network-hoarder_default.service"
      "podman-volume-hoarder_meilisearch.service"
    ];
    partOf = [
      "podman-compose-hoarder-root.target"
    ];
    wantedBy = [
      "podman-compose-hoarder-root.target"
    ];
  };
  virtualisation.oci-containers.containers."hoarder-web" = {
    image = "ghcr.io/hoarder-app/hoarder:release";
    environment = {
      "BROWSER_WEB_URL" = "http://chrome:9222";
      "DATA_DIR" = "/data";
      "MEILI_ADDR" = "http://meilisearch:7700";
      "OAUTH_WELLKNOWN_URL" = "https://dns.fluffy-rooster.ts.net/.well-known/openid-configuration";
      "OAUTH_CLIENT_SECRET" = "unused";
      "OAUTH_CLIENT_ID" = "unused";
      "OAUTH_PROVIDER_NAME" = "Tailscale";
      OAUTH_ALLOW_DANGEROUS_EMAIL_ACCOUNT_LINKING = "true";
    };
    labels = {
      "io.containers.autoupdate" = "registry";
    };
    environmentFiles = [ config.sops.secrets.hoarder_env.path ];
    volumes = [
      "hoarder_data:/data:rw"
    ];
    ports = [
      "3000:3000/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=web"
      "--network=hoarder_default"
    ];
  };
  systemd.services."podman-hoarder-web" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
    };
    after = [
      "podman-network-hoarder_default.service"
      "podman-volume-hoarder_data.service"
    ];
    requires = [
      "podman-network-hoarder_default.service"
      "podman-volume-hoarder_data.service"
    ];
    partOf = [
      "podman-compose-hoarder-root.target"
    ];
    wantedBy = [
      "podman-compose-hoarder-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-hoarder_default" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "podman network rm -f hoarder_default";
    };
    script = ''
      podman network inspect hoarder_default || podman network create hoarder_default
    '';
    partOf = [ "podman-compose-hoarder-root.target" ];
    wantedBy = [ "podman-compose-hoarder-root.target" ];
  };

  # Volumes
  systemd.services."podman-volume-hoarder_data" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect hoarder_data || podman volume create hoarder_data
    '';
    partOf = [ "podman-compose-hoarder-root.target" ];
    wantedBy = [ "podman-compose-hoarder-root.target" ];
  };
  systemd.services."podman-volume-hoarder_meilisearch" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      podman volume inspect hoarder_meilisearch || podman volume create hoarder_meilisearch
    '';
    partOf = [ "podman-compose-hoarder-root.target" ];
    wantedBy = [ "podman-compose-hoarder-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-hoarder-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
