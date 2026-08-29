{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.herdr;
in
{
  options.frgd.cli-apps.herdr = with types; {
    enable = mkBoolOpt false "Whether to enable herdr (terminal-native agent runtime).";
  };

  config = mkIf cfg.enable {
    programs.herdr = {
      enable = true;
      package = pkgs.herdr;
      settings = {
        onboarding = false;
        terminal.default_shell = "fish";
        theme.name = "gruvbox";
        keys.prefix = "ctrl+s";
      };
    };
  };
}
