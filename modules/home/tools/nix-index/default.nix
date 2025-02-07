{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.tools.nix-index;
in {
  options.frgd.tools.nix-index = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-index.";
  };

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
    };
  };
}
