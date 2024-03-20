{ lib, ... }:
with lib;
with lib.frgd; {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  frgd = {
    archetypes = {

    };

    security = { };
  };

}
