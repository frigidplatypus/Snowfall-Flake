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
  cfg = config.frgd.cli-apps.zoxide;
in
{
  options.frgd.cli-apps.zoxide = with types; {
    enable = mkBoolOpt false "zoxide";
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
    };
  };
}
