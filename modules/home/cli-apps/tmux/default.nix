{ lib, config, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.cli-apps.tmux;
in {
  options.frgd.cli-apps.tmux = { enable = mkEnableOption "Tmux"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tmux
      tmuxPlugins.gruvbox
      tmuxPlugins.fuzzback
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.mode-indicator
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.vim-tmux-focus-events
    ];
  };
}
