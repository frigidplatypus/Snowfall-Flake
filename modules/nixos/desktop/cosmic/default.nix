{
  options,
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.cosmic;
in
{
  options.frgd.desktop.cosmic = with types; {
    enable = mkBoolOpt false "cosmic";
  };

  config = mkIf cfg.enable {
    # Cosmic is Wayland-only; enable the Wayland input stack and common
    # system services needed for external touchscreens and Wi‑Fi devices.
    services.displayManager.cosmic-greeter.enable = lib.mkDefault true;

    # Use libinput for Wayland input devices (touchscreens, tablets, mice).
    # Use mkDefault so per-host hardware.nix or other modules can override.
    services.libinput.enable = lib.mkDefault true;

    # NetworkManager for Wi‑Fi management (mkDefault so hosts can disable).
    networking.networkmanager.enable = lib.mkDefault true;

    # Common kernel modules for USB / multitouch devices. Use mkDefault so
    # hosts that already declare kernel modules won't be overridden.
    boot.kernelModules = lib.mkDefault [
      "hid_multitouch"
      "i2c_hid"
      "usbtouchscreen"
    ];

    # Enable non-free firmware if the Wi‑Fi/touch hardware needs it.
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    services.desktopManager = {
      cosmic = {
        enable = true;
        xwayland = enabled;
      };
    };

  };
}
