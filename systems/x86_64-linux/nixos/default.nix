{ lib, ... }:
with lib;
with lib.frgd; {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  networking.hostName = "nixos"; # Define your hostname.
  services.getty.autologinUser = "justin";

  # List services that you want to enable:
  programs.git.enable = true;
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  frgd = { archetypes.server.enable = true; };

  programs.nix-ld.enable = true;

}
