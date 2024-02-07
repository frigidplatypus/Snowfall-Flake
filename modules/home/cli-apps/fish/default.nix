{ lib, config, pkgs, ... }:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.cli-apps.fish;
in {
  options.frgd.cli-apps.fish = { enable = mkEnableOption "fish"; };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAliases = {
        fs = "sudo nixos-rebuild switch --flake ~/Snowfall-Flake/#";
        ds = "darwin-rebuild switch --flake ~/Snowfall-Flake/#";
      };
      # shellInit = "op completion fish | source";
    };

    home.packages = with pkgs.fishPlugins; [
      z
      #hydro
      #      fzf
      #fzf-fish
      done
      #hydro
      colored-man-pages
      #pkgs.nerd-font-patcher
      pkgs.powerline
      pkgs.powerline-fonts
    ];

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
        format =
          "$sudo$shell$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$battery$character";
        #"$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$character";
        #shlvl = {
        #  disabled = false;
        #  symbol = "";
        #  style = "bright-white bold";
        #};
        #shell = {
        #  disabled = false;
        #  format = "$indicator";
        #  fish_indicator = "[><> ](bright-white bold)";
        #  bash_indicator = "[BASH](bright-white) ";
        #  zsh_indicator = "[ZSH](bright-white) ";
        #};
        username = {
          style_user = "bright-white bold";
          style_root = "bright-red bold";
        };
      };
    };
    home.sessionVariables = {
      theme_nerd_fonts = "yes";
      theme_color_scheme = "gruvbox";
    };

  };
}
