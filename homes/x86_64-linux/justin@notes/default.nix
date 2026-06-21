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
      tmux = enabled;
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

  # SilverBullet API Gateway — receives POST data and appends to a SB page
  services.silverbullet-api-gateway = {
    enable = true;
    url = "http://localhost:3000";
    page = "inbox";
    dataPattern = "- [ ] [TEXT] ([DATE])";
    tokenFile = config.sops.secrets."sb-token".path;
  };

  sops.secrets."sb-token" = { };
}
