{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  frgd = { archetypes.server.enable = true; };
}
