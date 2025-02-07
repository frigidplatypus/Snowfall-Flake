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
  cfg = config.frgd.apps.ghostty;
in
{
  options.frgd.apps.ghostty = with types; {
    enable = mkBoolOpt false "ghostty";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        theme = "GruvboxDarkHard";
      };
    };
  };
}
