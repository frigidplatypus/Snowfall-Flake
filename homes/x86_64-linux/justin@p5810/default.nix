{ lib, ... }:
with lib;
with lib.frgd; {
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
    desktop = { hyprland = enabled; };
    apps = { obsidian = enabled; };
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
    };
  };
}
