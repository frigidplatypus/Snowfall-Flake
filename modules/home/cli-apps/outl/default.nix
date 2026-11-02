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
    # The flake's own `outl` default builds the *upstream* release even
    # when the input points at a fork branch; `outl-dev` builds this
    # flake's pinned ref (here: frigidplatypus/outl experimental).
    # `outl-desktop-dev` is deliberately NOT defaulted: its build lists
    # `openssl_3`, which nixpkgs removed as EOL (2026-09-17), so it only
    # evaluates against outl's own older nixpkgs pin. Enable it explicitly
    # per-host once outl fixes that.
    programs.outl.package = mkDefault outlPackages.outl-dev;
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
