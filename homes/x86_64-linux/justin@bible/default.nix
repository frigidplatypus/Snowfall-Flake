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
  # frgd.services.silverbullet-api-gateway = {
  #   enable = true;
  #   sbUrl = "https://notes.fluffy-rooster.ts.net";   # was: url
  #   sbPage = "inbox";                                  # was: page
  #   # dataPattern = "- [ ] [TEXT] ([DATE])";
  # };
  # SilverBullet API Gateway — receives POST data and appends to a SB page
}
