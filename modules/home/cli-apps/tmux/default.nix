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
  cfg = config.frgd.cli-apps.tmux;

in
# Extrakto with wl-clipboard patched in.
{
  options.frgd.cli-apps.tmux = with types; {
    enable = mkBoolOpt false "Whether or not to enable tmux.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      mouse = true;
      keyMode = "vi";
      aggressiveResize = true;
      newSession = true;
      sensibleOnTop = true;
      # tmuxinator = true;
      shortcut = "s";
      plugins = with pkgs.tmuxPlugins; [
        cpu
        vim-tmux-navigator
        vim-tmux-focus-events
        urlview
        # tmux-fzf
        sysstat
        mode-indicator
        # jump
        gruvbox
        fingers
      ];
      extraConfig = ''
        set-option -g status-position top
        set-option -g status-left-length 30

      '';

    };
  };
}
