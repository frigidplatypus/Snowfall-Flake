{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.virtualization.docker;
in {
  options.frgd.virtualization.docker = with types; {
    enable = mkBoolOpt false "Whether or not to enable docker";
  };

  config = mkIf cfg.enable { virtualisation.docker.enable = true; };
}
