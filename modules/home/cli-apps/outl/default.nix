{
  config,
  lib,
  osConfig,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  outlPackages = inputs.outl.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Flake-wide defaults for the upstream outl Home Manager module
  # (inputs.outl.homeManagerModules.default → `programs.outl.*`).
  # Applies to every home that enables `programs.outl`; `mkDefault` keeps
  # per-host overrides winning without `force`.
  config = mkIf config.programs.outl.enable {
    # Upstream outlmd/outl ships the flake from #357: `outl` is the
    # release build of the pinned rev (the fork's `outl-dev` attr died
    # with the switch away from frigidplatypus/outl/experimental).
    programs.outl.package = mkDefault outlPackages.outl;
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
