{ config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.tools.charms;
in {
  options.frgd.tools.charms = with types; {
    enable = mkBoolOpt false "Whether or not to enable charms from charm.sh.";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ gum glow pop skate soft-serve wishlist ];
  };
}
