{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
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
    opencode
    inputs.html-to-markdown.packages.${pkgs.system}.html-to-markdown
    github-copilot-cli
    gemini-cli
    nh
  ];
  sops.secrets.vikunja_api_key = { };
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
      atuin = disabled;
      neovim = enabled;
      cliflux = enabled;
      home-manager = enabled;
      matrix_clients = enabled;
      system-monitors = enabled;
      taskwarrior = {
        enable = true;
        taskpirate = {
          enable = true;
          # hooksDir = "~/.local/share/task/hooks"; # optional override
          defaultDateTime = {
            enable = true;
            time = "07:00:00";
          };
          shiftRecurrence = {
            enable = true;
          };
        };
      };
      local-scripts = enabled;
      fish = {
        enable = true;
        extraShellAliases = {
          gam = "/Users/jmartin/bin/gam7/gam";
        };
      };
      nushell = enabled;
      tmux = enabled;
      zoxide = enabled;
      # cria = {
      #   enable = true;
      #   apiUrl = "https://tasks.${tailnet}";
      #   apiKeyFile = config.sops.secrets.vikunja_api_key.path;
      #   defaultFilter = "Western";
      #   # layouts = {
      #   #   default = {
      #   #     columns = [
      #   #       "id"
      #   #       "title"
      #   #       "due_date"
      #   #       "priority"
      #   #       "status"
      #   #     ];
      #   #     sortBy = "due_date";
      #   #     sortOrder = "asc";
      #   #   };
      #   # };
      #   quick_actions = [
      #     {
      #       key = "w";
      #       action = "project";
      #       target = "Western";
      #     }
      #     {
      #       key = "p";
      #       action = "project";
      #       target = "Personal";
      #     }
      #     {
      #       key = "q";
      #       action = "label";
      #       target = "qmlativ";
      #     }
      #   ];
      # };
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
