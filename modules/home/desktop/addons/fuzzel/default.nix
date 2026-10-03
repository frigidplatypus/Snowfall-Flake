{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.addons.fuzzel;
  palette = colorScheme.palette;
  fuzzelDmenu = "${pkgs.fuzzel}/bin/fuzzel -d";
in
{
  options.frgd.desktop.addons.fuzzel = with types; {
    enable = mkBoolOpt false "fuzzel launcher with a gruvbox theme and dmenu helpers.";
    terminal = mkOpt str "${pkgs.foot}/bin/foot" "Terminal used for Terminal=true apps.";
    matchMode = mkOption {
      type = types.enum [
        "exact"
        "fzf"
        "fuzzy"
      ];
      default = "fzf";
      description = "fuzzel match mode.";
    };
  };

  config = mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "${font-mono}:size=13";
          icon-theme = icon-theme; # Gruvbox-Plus-Dark
          icons-enabled = true;
          image-size-ratio = 0; # no giant single-match icon
          use-bold = true;
          gamma-correct-blending = false;
          dpi-aware = "auto";
          match-mode = cfg.matchMode;
          fields = "filename,name,generic,comment,keywords";
          show-actions = true;
          list-executables-in-path = false;
          terminal = cfg.terminal; # fuzzel default `$TERMINAL -e` breaks foot
          lines = 12;
          width = 60;
          horizontal-pad = 30;
          vertical-pad = 14;
          inner-pad = 10;
          line-height = 26;
          anchor = "center";
          keyboard-focus = "exclusive";
          exit-on-keyboard-focus-loss = true;
          enable-mouse = true;
          match-counter = true;
          auto-select = true;
          placeholder = "Type to run…";
          namespace = "fuzzel";
        };
        colors = {
          background = "${palette.base00}f5";
          text = "${palette.base06}ff";
          message = "${palette.base06}ff";
          prompt = "${palette.base09}ff";
          input = "${palette.base07}ff";
          placeholder = "${palette.base03}ff";
          counter = "${palette.base0D}ff";
          match = "${palette.base0A}ff";
          selection = "${palette.base02}ff";
          selection-text = "${palette.base07}ff";
          selection-match = "${palette.base0A}ff";
          border = "${palette.base03}ff";
        };
        border = {
          width = 2;
          radius = 12;
          selection-radius = 8;
        };
        dmenu.mode = "text";
      };
    };

    home.packages = with pkgs; [
      fuzzel
      calc
      cliphist
      wl-clipboard
      jq
      libnotify

      (writeShellScriptBin "fuzzel-clip" ''
        ${pkgs.cliphist}/bin/cliphist list \
          | ${fuzzelDmenu} --prompt="clip> " --with-nth=2 --minimal-lines \
          | ${pkgs.cliphist}/bin/cliphist decode \
          | ${pkgs.wl-clipboard}/bin/wl-copy
      '')

      (writeShellScriptBin "fuzzel-calc" ''
        expr=$(${fuzzelDmenu} --prompt="calc> " --placeholder="e.g. 2^16" --lines=1) || exit 0
        [ -n "$expr" ] || exit 0
        out=$(${pkgs.calc}/bin/calc -q -p "$expr" 2>&1) || {
          ${pkgs.libnotify}/bin/notify-send calc "error: $out"
          exit 1
        }
        printf '%s' "$out" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send calc "$out"
      '')

      (writeShellScriptBin "fuzzel-win" ''
        ${pkgs.niri}/bin/niri msg --json windows \
          | ${pkgs.jq}/bin/jq -r '.[] | select(.is_focused == false)
              | "\(.id)\t\(.app_id // "?")\t\(.title)"' \
          | ${fuzzelDmenu} --prompt="win> " --with-nth="{3}  {2}" --accept-nth=1 \
          | ${pkgs.niri}/bin/niri msg action focus-window --id
      '')
    ];
  };
}
