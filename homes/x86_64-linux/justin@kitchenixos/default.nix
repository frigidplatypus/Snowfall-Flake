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
      matrix_clients = enabled;
      obsidian = enabled;
      ghostty = enabled;
    };
    suites.common = {
      enable = true;
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
      taskwarrior = enabled;
    };

    tools = {
      git = enabled;
      ssh = enabled;
      lsd = enabled;
    };
  };
}
