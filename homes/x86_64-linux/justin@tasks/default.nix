{
  lib,
  config,
  # pkgs,
  ...
}:
with lib;
with lib.frgd;
{
  # home.packages = with pkgs; [ frgd.taskwarrior-api ];
  frgd = {
    security.sops = enabled;
    user = {
      enable = true;
      name = "justin";
    };
    services = {
      taskwarrior-sync = {
        enable = true;
      };
      taskwarrior-api = enabled;
    };

    cli-apps = {
      taskwarrior = enabled;
      ranger = enabled;
    };

  };
  sops.secrets.task_herald_ntfy = { };

  services.task-herald = {
    enable = true;
    settings = {
      # Required: notification service URL

      shoutrrr_url_file = config.sops.secrets.task_herald_ntfy.path;

      # Optional settings with defaults
      poll_interval = "30s";
      sync_interval = "30s";
      log_level = "info";

      # Web interface settings
      web = {
        host = "100.108.249.12";
        port = 8080;
        auth = false;
      };

      # Custom notification message template
      notification_message = "🔔 {{.Description}} (Due: {{.Due}})";
    };
  };
}
