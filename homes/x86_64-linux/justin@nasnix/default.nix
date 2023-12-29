{ lib, pkgs, config, osConfig ? { }, format ? "unknown", ... }:
with lib;
with lib.frgd; {
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    cli-apps = {
      fish = enabled;
      neovim = enabled;
      home-manager = enabled;
      tmux = enabled;
      ranger = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
    };
  };
}
