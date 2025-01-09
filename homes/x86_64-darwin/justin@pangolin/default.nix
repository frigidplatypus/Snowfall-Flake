{ lib, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    services = {
      espanso = {
        enable = true;
      };
    };

    apps = {
      kitty = enabled;
    };

    cli-apps = {
      neovim = enabled;
      home-manager = enabled;
      tmux = enabled;
      system-monitors = enabled;
      taskwarrior = {
        enable = true;
        dataLocation = "/Users/justin/Library/Mobile Documents/iCloud~com~mav~taskchamp/Documents/task";
      };
      #zellij = enabled;
      fish = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      bat = enabled;
      misc = enabled;
      charms = enabled;
    };
  };
  home.stateVersion = "24.05";

}
