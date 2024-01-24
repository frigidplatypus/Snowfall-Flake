{ config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.apps.obsidian;
in {
  options.frgd.apps.obsidian = with types; {
    enable = mkBoolOpt false "Whether or not to enable obsidian.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ obsidian ];
    nixpkgs.config.permittedInsecurePackages = [ "electron-24.8.6" ];
  };
}
