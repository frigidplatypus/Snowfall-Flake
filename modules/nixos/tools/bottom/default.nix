{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.bottom;
in
{
  options.frgd.tools.bottom = with types; {
    enable = mkBoolOpt false "Whether or not to enable Bottom.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bottom
    ];
  };
}
