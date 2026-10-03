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
        theme.auto_switch = false;
        ui.toast.delivery = "herdr";
        ui.show_agent_labels_on_pane_borders = true;
        keys.prefix = "ctrl+s";
        keys.command = [
          {
            key = "prefix+i";
            type = "plugin_action";
            command = "frigidplatypus.herdr-outl.capture-type";
            description = "outl: capture to today";
          }
          {
            key = "prefix+t";
            type = "plugin_action";
            command = "frigidplatypus.herdr-outl.today";
            description = "outl: today's journal (toggle)";
          }
          {
            key = "prefix+f";
            type = "plugin_action";
            command = "frigidplatypus.herdr-outl.goto";
            description = "outl: open a page";
          }
        ];
      };
    };
  };
}
