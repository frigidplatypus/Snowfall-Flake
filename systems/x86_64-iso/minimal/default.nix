{
  config,
  pkgs,
  options,
  lib,
  ...
}:
with lib;
with lib.frgd;
{

  frgd = {
    suites.installer = enabled;
  };
}
