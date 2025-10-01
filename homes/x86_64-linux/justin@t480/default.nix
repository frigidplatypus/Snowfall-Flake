{ lib, config, ... }:
with lib;
with lib.frgd;
{
  sops.secrets.vikunja_api_key = { };
  frgd = {
    suites.common = enabled;
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
      matrix_clients = enabled;
      ghostty = enabled;
    };
    security = {
      sops = {
        enable = true;
        miniflux_config = enabled;
      };
    };
    cli-apps = {
      aerc = enabled;
      neovim = enabled;
      home-manager = enabled;
      local-scripts = enabled;
      atuin = enabled;
      ranger = enabled;
      fish = enabled;
      taskwarrior = {
        enable = true;
        taskpirate = {
          enable = true;
          hooksDir = "~/.local/share/task/hooks";
        };
      };
      matrix_clients = enabled;
      hass-cli = enabled;
      cliflux = enabled;
      yazi = enabled;
      # neomutt = enabled;
      # zellij = enabled;
    };
    services = {
      espanso = {
        enable = true;
        western_snippets = {
          enable = true;
        };
      };
    };
    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
      charms = enabled;
      ssh = enabled;
      nix-index = enabled;
    };
  };
}
