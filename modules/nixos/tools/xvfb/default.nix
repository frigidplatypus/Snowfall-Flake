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
  cfg = config.frgd.tools.xvfb;
in
{
  options.frgd.tools.xvfb = with types; {
    enable = mkBoolOpt false "Whether or not to install xvfb-run and tigervnc for headless browser auth.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ xvfb-run tigervnc ];
  };
}
