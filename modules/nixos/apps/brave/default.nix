{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.apps.brave;
in {
  options.frgd.apps.brave = with types; {
    enable = mkBoolOpt false "Whether or not to enable the Brave browser.";
  };

  config =
    mkIf cfg.enable { environment.systemPackages = with pkgs; [ brave ]; };
}
