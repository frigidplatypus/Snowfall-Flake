{ channels, ... }:

final: prev:

{ inherit (channels.stable-nixpkgs) calibre-web; }
