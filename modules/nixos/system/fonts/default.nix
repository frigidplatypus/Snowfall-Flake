{
  options,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.system.fonts;
in
{
  options.frgd.system.fonts = with types; {
    enable = mkBoolOpt false "Whether or not to manage fonts.";
    fonts = mkOpt (listOf package) [ ] "Custom font packages to install.";
    fontpreview = mkBoolOpt false "Whether or not to install fontpreview.";

  };

  config = mkIf cfg.enable {
    environment.variables = {
      # Enable icons in tooling since we have nerdfonts.
      LOG_ICONS = "true";
    };

    #environment.systemPackages = with pkgs; [ font-manager ];

    fonts.packages =
      with pkgs;
      [
        # (nerdfonts.override { fonts = [ "Hack" ]; })
        # liberation_ttf
        fira-code
        fira-code-symbols
        # mplus-outline-fonts.githubRelease
        dina-font
        # proggyfonts
        font-awesome
        carlito # NixOS
        vegur # NixOS
        source-code-pro
        jetbrains-mono
        font-awesome # Icons
        fantasque-sans-mono
        # corefonts # MS
        nerd-fonts.fira-code
        nerd-fonts.hack
        nerd-fonts.inconsolata
        nerd-fonts.mononoki
        nerd-fonts.dejavu-sans-mono

      ]
      ++ cfg.fonts;
  };
}
