{ inputs, snowfall-inputs, lib, ... }:
let inherit (inputs) nix-colors;
in { colorScheme = nix-colors.colorSchemes.gruvbox-dark-medium; }
