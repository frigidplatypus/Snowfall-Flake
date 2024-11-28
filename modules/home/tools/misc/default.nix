{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.misc;
in
{
  options.frgd.tools.misc = with types; {
    enable = mkBoolOpt false "Whether or not to enable common utilities.";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      unzip
      wget
      fastfetch
      zip
      gdu
      yazi
      wakelan
    ];
  };
}
