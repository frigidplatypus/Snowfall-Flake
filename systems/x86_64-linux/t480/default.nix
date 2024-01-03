{ lib, ... }:
with lib;
with lib.frgd; {

  imports = [ ./hardware.nix ./disko.nix ];

  boot.supportedFilesystems = [ "zfs" ];

  # Enable fingerprint reader.
  services.open-fprintd.enable = true;
  services.python-validity.enable = true;

  frgd = {
    system.boot = {
      enable = true;
      efi = true;
    };
    archetypes = { workstation = enabled; };
    suites = {
      desktop = {
        enable = true;
        hyprland = true;
      };
    };
  };

}
