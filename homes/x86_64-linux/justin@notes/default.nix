{ lib, config, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common = enabled;

    security = {
      sops = {
        enable = true;
      };
    };

    cli-apps = {
      cliflux = enabled;
      herdr = enabled;
      # tmux = enabled;
      local-scripts = enabled;
    };

    tools = {
      git = {
        enable = true;
        internalGitKey = true;
      };
      misc = enabled;
    };
  };

  programs.outl = {
    enable = true;
    services.sync = {
      enable = true;
      workspace = "/home/justin/outl";
    };
  };
}
