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

      separator-color=${colorScheme.palette.base00}

      inside-color=${colorScheme.palette.base01}
      inside-clear-color=${colorScheme.palette.base0A}
      inside-caps-lock-color=${colorScheme.palette.base0F}
      inside-ver-color="${colorScheme.palette.base0B}44"
      inside-wrong-color=${colorScheme.palette.base08}

      ring-color=${colorScheme.palette.base09}
      ring-clear-color=${colorScheme.palette.base07} 
      ring-caps-lock-color=${colorScheme.palette.base08}
      ring-ver-color=${colorScheme.palette.base0B}
      ring-wrong-color=${colorScheme.palette.base0E} 

      line-color=${colorScheme.palette.base03}
      line-clear-color="ffd204FF"
      line-caps-lock-color=${colorScheme.palette.base08}
      line-ver-color=${colorScheme.palette.base0E}
      line-wrong-color=${colorScheme.palette.base02}

      text-clear-color=${colorScheme.palette.base00}
      text-ver-color=${colorScheme.palette.base03}
      text-wrong-color=${colorScheme.palette.base00}

      caps-lock-key-hl-color = "ffd204FF"
      caps-lock-bs-hl-color = "ee2e24FF"
      disable-caps-lock-text
      text-caps-lock-color = "009ddc"
    '';

    programs.swaylock = { package = pkgs.swaylock-effects; };
  };
}
