{ lib, config, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common-slim = enabled;

    security = {
      sops = {
        enable = true;
      };
    };

    cli-apps = {
      cliflux = enabled;
      tmux = enabled;
      local-scripts = enabled;
    };

    tools = {
      git = enabled;
      misc = enabled;
    };
  };
}
