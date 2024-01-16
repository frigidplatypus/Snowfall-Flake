{ lib, pkgs, ... }:
with lib;
with lib.frgd; {

  networking.firewall.enable = false;
  frgd = {
    suites = { common-slim = enabled; };
    archetypes.server = enabled;
    virtualization = {
      docker = enabled;
      libvirtd = enabled;
    };
  };
}
