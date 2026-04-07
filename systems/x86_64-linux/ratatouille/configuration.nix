# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];


  frgd = {

    nix = {
      enable = true;
      github-access-token = enabled;
    };
    system = {
      boot = {
        enable = true;
        efi = true;
      };
      zramSwap = enabled;
      zfs = enabled;
      fonts = {
        enable = true;
        fontpreview = true;
      };
    };
    security = {
      sops = {
        enable = true;
        taskwarrior = enabled;
      };
    };
    suites = {
      desktop = {
        enable = true;
      };
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;



  # Enable CUPS to print documents.
  services.printing.enable = true;


}
