{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.mdpdf;
in
{
  options.frgd.tools.mdpdf = with types; {
    enable = mkBoolOpt false "Whether or not to enable mdpdf.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      frgd.mdpdf
    ];
  };
}
