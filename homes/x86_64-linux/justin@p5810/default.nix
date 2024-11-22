{ lib, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
    desktop = {
      hyprland = enabled;
    };
    apps = {
      obsidian = enabled;
    };
    security = {
      sops = {
        enable = true;
        miniflux_config.enable = true;
      };
    };
    cli-apps = {
      neovim = enabled;
      home-manager = enabled;
      ranger = enabled;
      fish = enabled;
      taskwarrior = enabled;
      cliflux = enabled;
      # zellij = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
    };
  };
}
