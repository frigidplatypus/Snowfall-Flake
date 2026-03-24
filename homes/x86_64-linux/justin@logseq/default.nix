{ lib, ... }:
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
      tmux = enabled;
      ai-tools = enabled;
      yazi = enabled;
    };

    tools = {
      git = {
        enable = true;
        internalGitKey = true;
      };
      misc = enabled;
      charms = enabled;
    };
  };
}
