{ lib, pkgs, ... }:
with lib;
with lib.frgd; {
  imports = [ ./hardware.nix ];

  frgd = {
    archetypes.server.enable = true;
    security = {
      agenix = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    system.boot.grub = true;
  };
}
