inputs@{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.nh;
in
{
  options.frgd.cli-apps.nh = with types; {
    enable = mkBoolOpt false "Whether or not to enable nh.";
  };

  config = mkIf cfg.enable {
    home.Packages = with pkgs; [
      nh
      nix-output-monitor
      nvd
    ];
  };
}
