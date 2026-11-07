# shells/default/default.nix
# Generic devshell (`nix develop`). Snowfall auto-discovers shells/<name>/default.nix
# into devShells.<name>, called with the per-system package set.
#
# Tailor companions: nix/loader.nix (extra packages from nix/<lang>.nix drop-ins)
# and nix/hooks.nix (shell helper functions). Keep this file's own overrides last.
{
  pkgs,
  ...
}:
pkgs.mkShell {
  name = "flake-devshell";

  shellHook = ''
    ${import ../../nix/hooks.nix { inherit pkgs; }}
  '';

  packages =
    (with pkgs; [
      nixVersions.stable
      nixfmt
      deadnix
      statix
      treefmt
      # sops secrets
      sops
      # docs / helpers
      git
      gh
      just
      fd
      ripgrep
      fzf
      jq
      yq
      curl
    ])
    ++ import ../../nix/loader.nix { inherit pkgs; };
}
