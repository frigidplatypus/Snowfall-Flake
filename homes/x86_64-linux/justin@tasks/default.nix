{
  lib,
  # pkgs,
  ...
}:
with lib;
with lib.frgd;
{
  # home.packages = with pkgs; [ frgd.taskwarrior-api ];
  frgd = {
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
}
