{
  config,
  lib,
  osConfig,
  ...
}:
with lib;
{
  # Flake-wide defaults for the upstream outl Home Manager module
  # (inputs.outl.homeManagerModules.default → `programs.outl.*`).
  # Applies to every home that enables `programs.outl`; `mkDefault` keeps
  # per-host overrides winning without `force`.
  config = mkIf config.programs.outl.enable {
    programs.outl.settings = {
      tui.icons = mkDefault "nerd-font";
      # mode "dark" pins the desktop client too; the TUI renders presetDark regardless.
      theme = {
        preset = mkDefault "gruvbox";
        mode = mkDefault "dark";
      };
    };
  };
}
