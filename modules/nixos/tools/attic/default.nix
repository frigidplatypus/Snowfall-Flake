{ config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.tools.attic;
in {
  options.frgd.tools.attic = with types; {
    enable = mkBoolOpt false "Whether or not to enable Attic.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ ]; };
}
