{ lib, ... }:
with lib;
with lib.frgd; {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  networking.hostName = "t480"; # Define your hostname.

  frgd = {
    archetypes = {

    };

    security = {
      agenix = {
        enable = true;
        taskwarrior = enabled;
      };
    };
  };

}
