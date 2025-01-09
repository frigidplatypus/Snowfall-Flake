{ channels, ... }:

final: prev:

{ inherit (channels.stable-nixpkgs) matrix-synapse; }
