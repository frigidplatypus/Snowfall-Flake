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
  configFiles = lib.snowfall.fs.get-files ./config;

  # Extrakto with wl-clipboard patched in.

  plugins = (
    with pkgs.tmuxPlugins;
    [
      continuum
      gruvbox
      tilish
      tmux-fzf
      vim-tmux-navigator
    ]
  );
in
{
  options.frgd.cli-apps.tmux = with types; {
    enable = mkBoolOpt false "Whether or not to enable tmux.";
  };

  config = mkIf cfg.enable {
    frgd.home.extraOptions = {
      programs.tmux = {
        enable = true;
        # terminal = "screen-256color-bce";
        historyLimit = 2000;
        keyMode = "vi";
        newSession = true;
        extraConfig = builtins.concatStringsSep "\n" (builtins.map lib.strings.fileContents configFiles);

        inherit plugins;
      };
    };
  };
}
