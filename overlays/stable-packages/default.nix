{ channels, ... }:

final: prev:

{ inherit (channels.stable-nixpkgs) kitty n8n matrix-synapse; }
