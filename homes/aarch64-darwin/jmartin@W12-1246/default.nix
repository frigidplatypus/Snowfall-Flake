{ lib, ... }:
with lib;
with lib.frgd; {
  frgd = {
    apps = { circuit-python-editors = enabled; };
    services = {
      espanso = {
        enable = true;
        western_snippets = enabled;
      };
    };

    cli-apps = {
      #zsh = enabled;
      neovim = enabled;
      home-manager = enabled;
      tmux = enabled;
      system-monitors = enabled;
      taskwarrior = enabled;
      #zellij = enabled;
      # starship = enabled;
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

  home.stateVersion = "23.05";

}

