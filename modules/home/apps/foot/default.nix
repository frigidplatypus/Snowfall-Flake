{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
  let
    cfg = config.frgd.apps.foot;
    inherit (colorScheme) palette;
  in
  {
    options.frgd.apps.foot = with types; {
      enable = mkBoolOpt false "Whether or not to enable Foot.";
    };
  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = false;
      settings = {
        main = {
          term = "xterm-256color";
          font = "${font-mono}:size=16";
        };
        mouse = {
          hide-when-typing = "yes";
        };
        colors = {
          cursor = "${palette.base01} ${palette.base05}";
          # Base colors
          foreground = palette.base05; # ebdbb2 - Light foreground
          background = palette.base00; # 282828 - Dark background

          # Regular colors (0-7)
          regular0 = palette.base00; # 282828 - Black
          regular1 = palette.base08; # fb4934 - Red
          regular2 = palette.base0B; # b8bb26 - Green
          regular3 = palette.base0A; # fabd2f - Yellow
          regular4 = palette.base0D; # 83a598 - Blue
          regular5 = palette.base0E; # d3869b - Magenta
          regular6 = palette.base0C; # 8ec07c - Cyan
          regular7 = palette.base04; # bdae93 - Light gray

          # Bright colors (8-15)
          bright0 = palette.base03; # 665c54 - Dark gray
          bright1 = palette.base08; # fb4934 - Bright red
          bright2 = palette.base0B; # b8bb26 - Bright green
          bright3 = palette.base0A; # fabd2f - Bright yellow
          bright4 = palette.base0D; # 83a598 - Bright blue
          bright5 = palette.base0E; # d3869b - Bright magenta
          bright6 = palette.base0C; # 8ec07c - Bright cyan
          bright7 = palette.base05; # ebdbb2 - White

          # Extended colors
          "16" = palette.base09; # fe8019 - Orange
          "17" = palette.base0F; # d65d0e - Brown

          # Selection colors
          selection-foreground = palette.base00; # Dark text on light background
          selection-background = palette.base05; # Light background

          # Search colors
          search-box-no-match = "${palette.base00} ${palette.base08}"; # Background + Red
          search-box-match = "${palette.base05} ${palette.base0D}"; # Light + Blue

          # Jump labels
          jump-labels = "${palette.base00} ${palette.base09}"; # Background + Orange

          # URL color
          urls = palette.base0D; # 83a598 - Blue
        };
      };
    };

  };
}
