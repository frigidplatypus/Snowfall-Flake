{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.apps.logseq;
in
{
  options.frgd.apps.logseq = with types; {
    enable = mkBoolOpt false "Whether or not to enable logseq.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ logseq ];
    nixpkgs.config.permittedInsecurePackages = [ "electron-24.8.6" ];
  };
}
