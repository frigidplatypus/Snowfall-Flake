{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.tools.bat;
in {
  options.frgd.tools.bat = with types; {
    enable = mkBoolOpt false "Whether or not to enable bat.";
  };

  config = mkIf cfg.enable { programs.bat = { enable = true; }; };
}
