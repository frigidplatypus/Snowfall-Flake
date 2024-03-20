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
        fs =
          "figlet $(hostname); sudo nixos-rebuild switch --flake ~/Snowfall-Flake/#";
        fu = "cd ~/Snowfall-Flake/;flake update";
        fe = "cd ~/Snowfall-Flake/;nvim .";
        ds =
          "figlet $(hostname); darwin-rebuild switch --flake ~/Snowfall-Flake/#";
        dc = "docker compose";
        dcu = "docker compose up -d";
        dcd = "docker compose down";
        tt = "taskwarrior-tui";

      };
      # shellInit = "op completion fish | source";
    };

    home.packages = with pkgs.fishPlugins; [
      #hydro
      #      fzf
      #fzf-fish
      done
      #hydro
      colored-man-pages
      #pkgs.nerd-font-patcher
      pkgs.powerline-fonts
      pkgs.figlet
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
          "$sudo$username$hostname$nix_shell$directory$fill$direnv$git_branch$git_commit$git_state$git_status$jobs$cmd_duration$battery$line_break$character";
        #"$username$hostname$nix_shell$git_branch$git_commit$git_state$git_status$directory$jobs$cmd_duration$character";
        shlvl = {
          disabled = false;
          symbol = " ";
          style = "bright-white bold";
        };
        shell = {
          disabled = false;
          format = "[$indicator]($style)";
          fish_indicator = "[><> ](bright-white bold)";
          bash_indicator = "[BASH](bright-white) ";
          zsh_indicator = "[ZSH](bright-white) ";
        };
        sudo = {
          format = "[$symbol]($style)";
          symbol = "󰬬 ";
          disabled = false;
          style = "bright-red bold";
        };
        localip = {
          ssh_only = true;
          disabled = false;
        };
        direnv = { disabled = false; };
        line_break = { disabled = false; };
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
