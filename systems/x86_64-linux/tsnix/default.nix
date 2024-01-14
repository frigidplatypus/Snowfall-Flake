{ lib, pkgs, ... }:
with lib;
with lib.frgd; {

  imports = [ ./hardware.nix ./disko.nix];

  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };
    services = { espanso = enabled; tailscale.autoconnect = enabled; };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    suites = {common-slim = enabled;};
    virtualization = {libvirtd = enabled;};
  };
}
