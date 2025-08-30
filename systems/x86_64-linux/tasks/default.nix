{
  lib,
  modulesPath,
  pkgs,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  environment.systemPackages = with pkgs; [
    devenv
    direnv
  ];

  # Enable networking
  frgd = {
    archetypes.lxc = enabled;
    virtualization.docker = enabled;
    cli-apps.tmux = enabled;
    security.sops = enabled;
    services = {
      taskchampion = {
        enable = true;
      };
    };
  };
  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "tasks.fluffy-rooster.ts.net:8000";

  };

  sops.secrets.task_herald_ntfy = { };

  services.task-herald = {
    enable = true;
    settings = {
      # Required: notification service URL

      shoutrrr_url_file = config.sops.secrets.task_herald_ntfy.path;

      # Optional settings with defaults
      poll_interval = "30s";
      sync_interval = "5m";
      log_level = "info";

      # Web interface settings
      web = {
        listen = "127.0.0.1:8080";
        auth = false;
      };

      # Custom notification message template
      notification_message = "🔔 {{.Description}} (Due: {{.Due}})";
    };
  };
  services.caddy = {
    enable = true;
    virtualHosts = {
      "tasks.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:10222
          encode gzip
        '';
      };
      "tasks.${tailnet}:8000" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:3456
          encode gzip
        '';
      };
    };
  };
}
