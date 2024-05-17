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
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji
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
        # corefonts # MS
        # nerdfonts
        (nerdfonts.override {
          # Nerdfont Icons override
          fonts = [ "FiraCode" ];
        })
      ]
      ++ cfg.fonts;
  };
}
