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
      package = mkIf pkgs.stdenv.isDarwin null;
      enableFishIntegration = true;
      settings = {
        theme = "Gruvbox Dark Hard";
        font-size = 15;
        font-family = "Fantesque Sans Mono";
        working-directory = "home";
        window-inherit-working-directory = false;
      };
    };
  };
}
