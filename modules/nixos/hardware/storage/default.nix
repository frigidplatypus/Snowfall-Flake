{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.hardware.storage;
in
{
  options.frgd.hardware.storage = with types; {
    enable = mkBoolOpt false "Whether or not to enable support for extra storage devices.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ntfs3g
      fuseiso
    ];
  };
}
