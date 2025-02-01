{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.system.zramSwap;
in
{
  options.frgd.system.zramSwap = with types; {
    enable = mkBoolOpt false "Whether or not to enable zramSwapping.";
  };

  config = mkIf cfg.enable {
    zramSwap = enabled;
  };
}
