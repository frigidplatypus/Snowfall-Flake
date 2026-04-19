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
      logseq = enabled;
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

    security = {
      sops = enabled;
    };

    tools = {
      git = {
        enable = true;
        internalGitKey = true;
      };
      ssh = enabled;
      lsd = enabled;
    };
  };
}
