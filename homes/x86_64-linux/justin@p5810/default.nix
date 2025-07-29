{ lib,config, ... }:
with lib;
with lib.frgd;
{
  sops.secrets.vikunja_api_key = { };
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common = enabled;
    desktop = {
      hyprland = enabled;
    };

    security = {
      sops = {
        enable = true;
        miniflux_config.enable = true;
      };
    };

    cli-apps = {
      taskwarrior = enabled;
      cliflux = enabled;
      tmux = enabled;
      cria = {
        enable = true;
        apiUrl = "https://tasks.fluffy-rooster.ts.net";
        apiKeyFile = config.sops.secrets.vikunja_api_key.path;
        defaultProject = "Inbox";
        defaultFilter = "Personal";
        quick_actions = [
          {
            key = "w";
            action = "project";
            target = "Western";
          }
          {
            key = "p";
            action = "project";
            target = "Personal";
          }
          {
            key = "n";
            action = "label";
            target = "nix";
          }
          {
            key = "e";
            action = "label";
            target = "email";
          }
        ];
      };
    };

    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
      charms = enabled;
    };
  };
}
