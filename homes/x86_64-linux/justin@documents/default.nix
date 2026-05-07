{ lib, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    security.sops = enabled;

    tools.git = {
      enable = true;
      internalGitKey = true;
    };
  };
}
