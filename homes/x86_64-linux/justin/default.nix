{
  lib,
  ...
}:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
    security = {
      sops = {
        enable = true;
      };
    };

    cli-apps = {
      # fish = enabled;
      # neovim = enabled;
      home-manager = enabled;
      # tmux = enabled;
    };

    tools = {
      git = {
        enable = true;
        internalGitKey = true;
      };
      # misc = enabled;
    };
  };
}
