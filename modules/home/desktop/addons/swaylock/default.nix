{ lib, config, pkgs, ... }:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.desktop.addons.swaylock;
in {
  options.frgd.desktop.addons.swaylock = {
    enable = mkEnableOption "Swaylock";
  };

  config = mkIf cfg.enable {
    xdg.configFile."swaylock/config".text = ''
      ignore-empty-password
      clock
      timestr=%I:%M %p
      screenshots
      #fade-in=.2
      effect-blur=12x12
      effect-scale=0.3
      effect-pixelate=4
      indicator
      indicator-radius=200
      indicator-thickness=20
      indicator-caps-lock

      separator-color=${colorScheme.colors.base00}

      inside-color=${colorScheme.colors.base01}
      inside-clear-color=${colorScheme.colors.base0A}
      inside-caps-lock-color=${colorScheme.colors.base0F}
      inside-ver-color="${colorScheme.colors.base0B}44"
      inside-wrong-color=${colorScheme.colors.base08}

      ring-color=${colorScheme.colors.base09}
      ring-clear-color=${colorScheme.colors.base07} 
      ring-caps-lock-color=${colorScheme.colors.base08}
      ring-ver-color=${colorScheme.colors.base0B}
      ring-wrong-color=${colorScheme.colors.base0E} 

      line-color=${colorScheme.colors.base03}
      line-clear-color="ffd204FF"
      line-caps-lock-color=${colorScheme.colors.base08}
      line-ver-color=${colorScheme.colors.base0E}
      line-wrong-color=${colorScheme.colors.base02}

      text-clear-color=${colorScheme.colors.base00}
      text-ver-color=${colorScheme.colors.base03}
      text-wrong-color=${colorScheme.colors.base00}

      caps-lock-key-hl-color = "ffd204FF"
      caps-lock-bs-hl-color = "ee2e24FF"
      disable-caps-lock-text
      text-caps-lock-color = "009ddc"
    '';

    programs.swaylock = { package = pkgs.swaylock-effects; };
  };
}
