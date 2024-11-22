{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.neomutt;
in
{
  options.frgd.cli-apps.neomutt = with types; {
    enable = mkBoolOpt false "neomutt";
  };

  config = mkIf cfg.enable {
    programs.neomutt = {
      enable = true;
      vimKeys = true;
    };
  };
}
