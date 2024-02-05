{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.apps.signal;
in {
  options.frgd.apps.signal = with types; {
    enable = mkBoolOpt false "Whether or not to enable signal.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ signal-desktop ];
  };
}
