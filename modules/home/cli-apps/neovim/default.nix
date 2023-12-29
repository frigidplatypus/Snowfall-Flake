{ lib, config, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.cli-apps.neovim;
in {
  options.frgd.cli-apps.neovim = { enable = mkEnableOption "Neovim"; };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        less
        rnix-lsp
        nixfmt
        ripgrep
        alejandra
        nodejs
        gcc
      ];

      sessionVariables = {
        PAGER = "less";
        MANPAGER = "less";
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
        EDITOR = "nvim";
      };

      shellAliases = { vimdiff = "nvim -d"; };
    };

    programs.neovim = {
      enable = true;
      #     defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
