{
  lib,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  frgd = {
    security.sops = enabled;
    user = {
      enable = true;
      name = "justin";
    };

    cli-apps = {
      ranger = enabled;
    };

  };
}
