{
  # options,
  config,
  # pkgs,
  lib,
  inputs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.hardware.fingerprint;
in
{
  options.frgd.hardware.fingerprint = with types; {
    enable = mkBoolOpt false "Whether or not to enable fingerprint support.";
    t480 = mkBoolOpt false "Whether or not to enable t480 support.";
  };

  config = mkIf cfg.enable {
    services.fprintd = {
      enable = true;
      tod = mkIf cfg.t480 {
        enable = true;
        driver = inputs.nixos-06cb-009a-fingerprint-sensor.lib.libfprint-2-tod1-vfs0090-bingch {
          calib-data-file = ./calib-data.bin;
        };
      };
    };
  };
}
