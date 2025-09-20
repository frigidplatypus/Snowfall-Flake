{
  lib,
  config,
  pkgs,
  ...
}:

  with lib;
  with lib.frgd;
  let
    cfg = config.frgd.cli-apps.neovim;
  in
  {
    options.frgd.cli-apps.neovim = with types; {
      enable = mkBoolOpt false "Whether or not to enable Neovim.";
    };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        # less
        # #rnix-lsp
        # nixfmt-rfc-style
        # ripgrep
        # alejandra
        # nodejs
        # gcc
        # rustc
        # cargo
        # nil
        frgd.neovim
      ];

      sessionVariables = {
        PAGER = "less";
        MANPAGER = "less";
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
        EDITOR = "nvim";
      };

      shellAliases = {
        vimdiff = "nvim -d";
      };
    };


  };
}
