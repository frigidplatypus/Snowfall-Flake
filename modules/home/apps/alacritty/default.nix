{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.apps.alacritty;
in
{
  options.frgd.apps.alacritty = with types; {
    enable = mkBoolOpt false "Whether or not to enable alacritty.";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        font.size = 24;
        decorations = "buttonless";
      };

    };

  };
}
