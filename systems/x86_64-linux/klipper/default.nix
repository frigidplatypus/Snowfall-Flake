{ lib, pkgs, ... }:
with lib;
with lib.frgd;
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Enable networking
  networking = {
    networkmanager.enable = true;
  };
  networking.firewall.enable = false;

  frgd = {
    nix = enabled;
    archetypes.server = enabled;
    security.sops = enabled;
    services = {
      syncthing = enabled;
      klipper = enabled;
    };
    system.boot.efi = true;
    system.boot.oldBoot = true;
    # Ensure the user can access serial devices
    user.extraGroups = [
      "moonraker"
      "dialout"
    ];
  };

  # Make the klipper service restart on failure so it will retry connecting
  # and bind to the serial device unit so systemd stops/starts it when the
  # device appears/disappears. Escape '-' as \x2d in unit names.
  systemd.services."klipper".serviceConfig = {
    Restart = "always";
    RestartSec = "5s";
    BindsTo = [ "dev-serial-by\x2did-usb-Klipper_stm32f103xe_33FFD5054242363213680157-if00.device" ];
    After = [ "dev-serial-by\x2did-usb-Klipper_stm32f103xe_33FFD5054242363213680157-if00.device" ];
  };

}
