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
  cfg = config.frgd.cli-apps.ranger;
in
{
  options.frgd.cli-apps.ranger = with types; {
    enable = mkBoolOpt false "ranger";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ranger

    ];
  };
}
