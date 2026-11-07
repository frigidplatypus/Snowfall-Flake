# Package loader consumed by the devshell (shells/default/default.nix).
# Tailor-managed companion: drop a nix/<lang>.nix exporting a package list
# (go.nix, python.nix, rust.nix, ...) and the devshell picks it up.
{ pkgs, ... }:
builtins.seq pkgs (
  builtins.concatLists [
    (if builtins.pathExists ./go.nix then import ./go.nix { inherit pkgs; } else [ ])
    (if builtins.pathExists ./python.nix then import ./python.nix { inherit pkgs; } else [ ])
    (if builtins.pathExists ./rust.nix then import ./rust.nix { inherit pkgs; } else [ ])
  ]
)
