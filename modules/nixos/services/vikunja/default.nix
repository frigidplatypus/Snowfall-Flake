{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.vikunja;
in {
  options.frgd.services.vikunja = with types; {
    enable = mkBoolOpt false "Whether or not to enable vikunja.";
  };

  config = mkIf cfg.enable { services = { vikunja = { enable = true; }; }; };
}

