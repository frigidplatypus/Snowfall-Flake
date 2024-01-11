{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.apps.foot;
in {
  options.frgd.apps.foot = with types; {
    enable = mkBoolOpt false "Whether to enable the gnome file manager.";
  };

  config =
    mkIf cfg.enable { environment.systemPackages = with pkgs; [ foot ]; };
}
