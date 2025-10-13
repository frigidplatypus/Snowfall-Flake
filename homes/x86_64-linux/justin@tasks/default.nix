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
      endpoint = "https://ntfy.${tailnet}";
      topic = "taskherald";
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
