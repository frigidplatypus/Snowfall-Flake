{ channels, ... }:

final: prev:

{ inherit (channels.stable-nixpkgs) opencode; }
