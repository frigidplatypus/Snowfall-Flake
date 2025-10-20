{
  options,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.qmk;
in
{
  options.frgd.tools.qmk = with types; {
    enable = mkBoolOpt false "Whether or not to enable QMK";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      qmk
      vial
    ];

    hardware.keyboard.qmk.enable = true;

    services.udev.packages = with pkgs; [ qmk-udev-rules ];
  };
}
