{ lib, config, ... }:
with lib;
with lib.frgd;
{
  sops.secrets.apple_app_password = { };

  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common = enabled;

    security.sops = enabled;

    cli-apps = {
      sbtask = enabled;
      ai-tools = enabled;
    };

    tools = {
      git = enabled;
      misc = enabled;
    };
  };
}
