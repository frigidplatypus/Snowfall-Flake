{ lib, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };
    apps = {
      kitty = enabled;
      matrix_clients = {
        enable = true;
      };
    };
    suites.common = {
      enable = true;
    };
    cli-apps = {
      taskwarrior = enabled;
    };
    services = {
      espanso = enabled;
    };
    cli-apps = {
      zoxide = enabled;
      neovim = enabled;
      home-manager = enabled;
      ranger = enabled;
      fish = enabled;
    };

    tools = {
      git = enabled;
      ssh = enabled;
      lsd = enabled;
    };
  };
}
