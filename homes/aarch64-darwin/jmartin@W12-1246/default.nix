{ lib, pkgs, ... }:
with lib;
with lib.frgd;
{
  home.packages = with pkgs; [
    xkcdpass
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.zed-mono
    nerd-fonts.symbols-only
    nerd-fonts.space-mono
    nerd-fonts.sauce-code-pro

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

    security = {
      sops = {
        enable = true;
        miniflux_config = enabled;
      };

    };

    cli-apps = {
      #zsh = enabled;
      neovim = enabled;
      cliflux = enabled;
      home-manager = enabled;
      matrix_clients = enabled;
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
