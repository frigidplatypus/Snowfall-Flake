{ lib, pkgs, ... }:
with lib;
with lib.frgd; {

  networking.firewall.enable = false;

  frgd = {
    suites.installer = enabled;
    security.sops = { enable = true; };
  };
}
