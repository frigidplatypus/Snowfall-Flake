{ lib, pkgs, ... }:
with lib;
with lib.frgd;
{
  home.packages = with pkgs; [
    xkcdpass
  ];
  frgd = {
    apps = {
      # circuit-python-editors = enabled;
    };
    services = {
      espanso = {
        enable = true;
        western_snippets = enabled;
      };
    };

    apps = {
      kitty = enabled;
    };

    cli-apps = {
      #zsh = enabled;
      neovim = enabled;
      home-manager = enabled;
      system-monitors = enabled;
      taskwarrior = enabled;
      fish = enabled;
      nushell = enabled;
      tmux = enabled;
      zoxide = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      bat = enabled;
      misc = enabled;
      lsd = enabled;
      charms = enabled;
    };
  };

  home.stateVersion = "24.05";
}
