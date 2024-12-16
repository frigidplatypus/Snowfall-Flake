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
  cfg = config.frgd.homebrew;
in
{
  options.frgd.homebrew = with types; {
    enable = mkBoolOpt false "Whether or not to enable Homebrew.";

    casks = {
      enable = mkBoolOpt false "Whether or not to install cassks via Homebrew.";
    };
  };

  config = mkIf cfg.enable {

    homebrew = {
      enable = true;
      caskArgs.no_quarantine = true;
      global.brewfile = true;
      masApps = { };
      casks = mkIf cfg.casks.enable [
        "raycast"
        "amethyst"
        "omnifocus"
        "logseq"
        "bartender"
        "1password"
        "element"
        "karabiner-elements"
        "openscad"
        "syncthing"
        "iterm2"
        "keyboard-maestro"
        "popclip"
        "numi"
        "visual-studio-code"
        "vial"
        "beeper"
        "cyberduck"
        "obsidian"
        "zed"
        "wezterm"
        "kitty"
        "alacritty"
        "heynote"
        "sourcetree"
        "font-fantasque-sans-mono"
        "nikitabobko/tap/aerospace"
        "element"
        "background-music"
      ];
    };

  };
}
