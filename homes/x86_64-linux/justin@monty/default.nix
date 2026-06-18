{ lib, config, ... }:
with lib;
with lib.frgd;
{
  sops.secrets.apple_app_password = { };

  programs.sbtask = {
    enable = true;
    settings = {
      spaces = {
        main = {
          space = "https://notes.fluffy-rooster.ts.net";
          defaultPage = "Tasks";
        };
        household = {
          space = "https://notes.fluffy-rooster.ts.net";
          defaultPage = "HouseholdTasks";
        };
      };
      activeSpace = "main";
    };
  };

  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common = enabled;

    security.sops = enabled;

    cli-apps = {
      ai-tools = enabled;
    };

    tools = {
      git = enabled;
      misc = enabled;
    };
  };
}
