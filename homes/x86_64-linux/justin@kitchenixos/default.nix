{ lib, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
    apps = {
      kitty = enabled;
    };
    cli-apps = {
      atuin = enabled;
      taskwarrior = enabled;
    };
    services = {
      espanso = enabled;
    };
  };
}
