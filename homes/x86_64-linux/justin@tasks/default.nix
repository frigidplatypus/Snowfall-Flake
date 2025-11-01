{
  lib,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  # home.packages = with pkgs; [ frgd.taskwarrior-api ];
  services.taskherald = {
    enable = true;
    settings = {
      ntfy_topic = "taskherald"; # OR use ntfy_topic_file below
      ntfy_server = "https://ntfy.${tailnet}"; # Optional
      taskherald_interval = 15; # Optional
    };
  };
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

}
