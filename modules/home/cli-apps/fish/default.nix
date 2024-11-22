{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.cli-apps.fish;
in
{
  options.frgd.cli-apps.fish = {
    enable = mkEnableOption "fish";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAliases = {
        fs = "figlet $(hostname); sudo nixos-rebuild switch --flake ~/Snowfall-Flake/#";
        fu = "cd ~/Snowfall-Flake/;flake update";
        fe = "cd ~/Snowfall-Flake/;nvim .";
        ds = "figlet $(hostname); darwin-rebuild switch --flake ~/Snowfall-Flake/#";
        tt = "taskwarrior-tui";
      };
      shellInitLast = ''
        alias cd=z
        alias cdi=zi
      '';
    };

    home.packages = with pkgs.fishPlugins; [
      fzf-fish
      grc
      # fifc
      gruvbox
      sponge
      forgit
      colored-man-pages
      pkgs.powerline-fonts
      pkgs.figlet
      pkgs.grc
    ];

    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    programs.carapace = {
      enable = true;
      enableFishIntegration = true;
    };
    programs.bash.enable = true;
    programs.zsh.enable = true;
    programs.nushell.enable = true;
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
        format = "$sudo$shell$username$hostname$battery$nix_shell$directory$character";
        right_format = "$localip$direnv$git_branch$git_commit$git_state$git_status$jobs$cmd_duration";

        shlvl = {
          disabled = false;
          symbol = " ";
          style = "bright-white bold";
        };
        directory = {
          disabled = false;
          fish_style_pwd_dir_length = 2;
          truncation_length = 2;
        };
        shell = {
          disabled = false;
          format = "[$indicator]($style)";
          fish_indicator = "[](bright-white bold)";
          bash_indicator = "[BASH](bright-white bold) ";
          zsh_indicator = "[ZSH](bright-white bold) ";
          nu_indicator = "[Nu](bright-white bold) ";
          powershell_indicator = "[>_](bright-white) ";
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
        direnv = {
          disabled = false;
        };
        battery = {
          disabled = false;
        };
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
