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

    cli-apps = {
      neovim = enabled;
      home-manager = enabled;
      tmux = enabled;
      system-monitors = enabled;
      taskwarrior = enabled;
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
  programs.taskwarrior.dataLocation = "/Users/justin/Library/Mobile Documents/iCloud~com~mav~taskchamp/Documents/task";
  home.stateVersion = "24.05";

}
