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
    extraShellAliases = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Extra shell aliases to add to fish.
        These will be merged with the default ones.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      shellAliases = mkMerge [
        { }
        cfg.extraShellAliases
      ];
      interactiveShellInit = ''
        ${pkgs.cfonts}/bin/cfonts FrigidPlatypus -f tiny -g "#cc241d,#d79921,#458588,#8ec07c" -t -a center

        set host (hostname)
        set ip (hostname -I | awk '{print $1}')

        # Battery detection
        if test -f /sys/class/power_supply/BAT0/capacity
          set battery (cat /sys/class/power_supply/BAT0/capacity)%
        else if test -f /sys/class/power_supply/BAT1/capacity
          set battery (cat /sys/class/power_supply/BAT1/capacity)%
        else
          set battery ""
        end

        # Improved Tailscale detection
        if type -q tailscale
          set tailscale_ip (tailscale ip --4 2>/dev/null | head -n 1)
          if test -n "$tailscale_ip"
            set network "IP: $ip / $tailscale_ip"
          else
            set network "IP: $ip"
          end
        else
          set network "IP: $ip"
        end

        # Compose info line
        set info_line "Hostname: $host | $network"
        if test -n "$battery"
          set info_line "$info_line | Battery: $battery"
        end

        # Get terminal width and pad/trim as needed
        set term_width (math (tput cols) - 4)
        set info_line (string sub -l $term_width -- $info_line)

        ${pkgs.gum}/bin/gum style --border double --padding "0" --margin "0" --width $term_width --align center --foreground "#458588" --background "#282828" "$info_line"
      '';
      shellInitLast = ''
        alias cd=z
        alias cdi=zi
      '';
    };

    home.packages = with pkgs.fishPlugins; [
      grc
      # fifc
      gruvbox
      sponge
      forgit
      colored-man-pages
      pkgs.powerline-fonts
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
    programs.zoxide = {
      enable = true;
    };
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
