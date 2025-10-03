{ channels, ... }:

final: prev:

{ inherit (channels.stable-nixpkgs) kitty; }
