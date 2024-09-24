{ lib, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
    cli-apps = {
      atuin = enabled;
    };
    services = {
      espanso = enabled;
    };
  };
}
