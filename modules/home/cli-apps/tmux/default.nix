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
{
  options.frgd.cli-apps.tmux = with types; {
    enable = mkBoolOpt false "Whether or not to enable tmux.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      sensibleOnTop = true;
      baseIndex = 1;
      mouse = true;
      keyMode = "vi";
      newSession = true;
      shell = "${pkgs.fish}/bin/fish";
      tmuxinator.enable = true;
      shortcut = "s";
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        vim-tmux-focus-events
        urlview
        # tmux-fzf
        gruvbox
      ];
      extraConfig = ''
        set-option -g status-position top
        set-option -g status-left-length 30
      '';
    };
  };
}
