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
  cfg = config.frgd.apps.chromium;
in
{
  options.frgd.apps.chromium = with types; {
    enable = mkBoolOpt false "Whether or not to enable Chromium browser.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ chromium ];
  };
}
