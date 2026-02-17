{
  lib,
  pkgs,
  config,
  osConfig ? { },
  format ? "unknown",
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

    cli-apps = {
      ai-tools = enabled;
      fish = enabled;
      neovim = enabled;
      home-manager = enabled;
      ranger = enabled;
      tmux = enabled;
      yazi = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
    };
  };
}
