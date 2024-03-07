{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.tools.lsd;
in {
  options.frgd.tools.lsd = with types; {
    enable = mkBoolOpt false "Whether or not to enable lsd.";
  };

  config = mkIf cfg.enable { environment.systemPackages = with pkgs; [ lsd ]; };
}
