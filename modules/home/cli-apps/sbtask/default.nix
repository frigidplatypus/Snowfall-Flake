{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.sbtask;
in
{
  options.frgd.cli-apps.sbtask = with types; {
    enable = mkBoolOpt false "Whether to enable sbtask (SilverBullet task CLI) with multi-space config.";

    spaces = mkOption {
      type = attrsOf (submodule {
        options = {
          space = mkOption {
            type = str;
            description = "SilverBullet space URL.";
          };
          defaultPage = mkOption {
            type = str;
            default = "Tasks";
            description = "Default page for new tasks in this space.";
          };
        };
      });
      default = {
        main = {
          space = "https://notes.fluffy-rooster.ts.net";
          defaultPage = "Tasks";
        };
        household = {
          space = "https://notes.fluffy-rooster.ts.net";
          defaultPage = "HouseholdTasks";
        };
      };
      description = "Named SilverBullet spaces for task management.";
    };

    activeSpace = mkOption {
      type = str;
      default = "main";
      description = "The default active space name.";
    };
  };

  config = mkIf cfg.enable {
    programs.sbtask = {
      enable = true;
      settings = {
        spaces = cfg.spaces;
        activeSpace = cfg.activeSpace;
      };
    };
  };
}
