{ config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.tools.attic;
in {
  options.frgd.tools.attic = { enable = mkEnableOption "Attic"; };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ ]; };
}
