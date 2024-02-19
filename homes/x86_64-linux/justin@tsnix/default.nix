{ lib, ... }:
with lib;
with lib.frgd; {
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    cli-apps = {
      neovim = enabled;
      home-manager = enabled;
      tmux = enabled;
      ranger = enabled;
      fish = enabled;
      taskwarrior = enabled;
      # zellij = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
      charms = enabled;
    };
  };
}
