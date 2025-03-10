{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.apps.foot;
in
{
  options.frgd.apps.foot = {
    enable = mkEnableOption "Foot";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nerd-fonts.agave
    ];
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {

        main = {
          term = "xterm-256color";
          font = "Agave Nerd Font Mono:size=16";
        };

        mouse = {
          hide-when-typing = "yes";
        };

        cursor.color = "181926 f4dbd6";

        colors = {

          foreground = "cad3f5";
          background = "24273a";

          regular0 = "494d64";
          regular1 = "ed8796";
          regular2 = "a6da95";
          regular3 = "eed49f";
          regular4 = "8aadf4";
          regular5 = "f5bde6";
          regular6 = "8bd5ca";
          regular7 = "b8c0e0";

          bright0 = "5b6078";
          bright1 = "ed8796";
          bright2 = "a6da95";
          bright3 = "eed49f";
          bright4 = "8aadf4";
          bright5 = "f5bde6";
          bright6 = "8bd5ca";
          bright7 = "a5adcb";

          "16" = "f5a97f";
          "17" = "f4dbd6";

          selection-foreground = "cad3f5";
          selection-background = "454a5f";

          search-box-no-match = "181926 ed8796";

          search-box-match = "cad3f5 363a4f";

          jump-labels = "181926 f5a97f";

          urls = "8aadf4";
        };

      };

    };
  };
}
