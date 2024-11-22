{ lib, config, ... }:
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
      kitty = enabled;
    };
    security = {
      sops = {
        enable = true;
        miniflux_config = enabled;
      };
    };
    cli-apps = {
      neovim = enabled;
      home-manager = enabled;
      ranger = enabled;
      fish = enabled;
      taskwarrior = enabled;
      matrix_clients = enabled;
      hass-cli = enabled;
      cliflux = {
        enable = true;
      };
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
