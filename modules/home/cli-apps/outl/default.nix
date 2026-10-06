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
    # The flake's own `outl`/`outl-desktop` defaults build the *upstream*
    # release even when the input points at a fork branch; the `-dev`
    # variants build this flake's pinned ref (here: frigidplatypus/outl
    # experimental). `mkDefault` keeps per-host overrides winning.
    programs.outl = {
      package = mkDefault outlPackages.outl-dev;
      desktopPackage = mkDefault outlPackages.outl-desktop-dev;
    };
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
