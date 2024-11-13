{
  lib,
  ...
}:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
    services.taskwarrior-sync = {
      enable = true;
    };

    cli-apps = {
      taskwarrior = enabled;
      ranger = enabled;
    };

  };
}
