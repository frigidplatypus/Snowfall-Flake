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

      # Optional settings with defaults
      poll_interval = "30s";
      sync_interval = "30s";
      log_level = "info";

      # Web interface settings
      # web = {
      #   host = "100.108.249.12";
      #   port = 8080;
      #   domain = "tasks.${tailnet}";
      # };

      ntfy = {
        url = "https://ntfy.sh";
        topic_file = config.sops.secrets.task_herald_ntfy.path;
        token = "";
        headers = {
          X-Title = "{{.Project}}";
          X-Default = "{{.Priority}}";
        };
        actions_enabled = true;
      };

      # Custom notification message template
      # notification_message = "🔔 {{.Description}} (Due: {{.Due}})";

      udas = {
        notification_date = "notification_date";
        repeat_enable = "notification_repeat_enable";
        repeat_delay = "notification_repeat_delay";
      };
    };

  };
}
