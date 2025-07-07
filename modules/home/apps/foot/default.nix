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

          foreground = "ebdbb2";
          background = "282828";

          regular0 = "282828";
          regular1 = "cc241d";
          regular2 = "98971a";
          regular3 = "d79921";
          regular4 = "458588";
          regular5 = "b16286";
          regular6 = "689d6a";
          regular7 = "a89984";

          bright0 = "928374";
          bright1 = "fb4934";
          bright2 = "b8bb26";
          bright3 = "fabd2f";
          bright4 = "83a598";
          bright5 = "d3869b";
          bright6 = "8ec07c";
          bright7 = "ebdbb2";

          "16" = "fe8019";
          "17" = "d65d0e";

          selection-foreground = "282828";
          selection-background = "ebdbb2";

          search-box-no-match = "282828 fb4934";

          search-box-match = "ebdbb2 458588";

          jump-labels = "282828 fe8019";

          urls = "458588";
        };

      };

    };
  };
}
