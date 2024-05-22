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
      hyprland = {
        enable = true;
        extra-config = {
          monitor = "eDP-1, 1920x1080, 0x0, 1";
        };
      };
    };
    apps = {
      obsidian = enabled;
    };
    cli-apps = {
      neovim = enabled;
      home-manager = enabled;
      tmux = enabled;
      ranger = enabled;
      fish = enabled;
      taskwarrior = enabled;
      matrix_clients = enabled;
      hass-cli = enabled;
      # neomutt = enabled;
      # zellij = enabled;
    };
    services = {
      espanso = enabled;
    };
    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
      charms = enabled;
      ssh = enabled;
    };
  };
}
