{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.addons.sddm;
  sddm-astronaut = pkgs.sddm-astronaut.override {
    themeConfig = {
      AccentColor = "#${colorScheme.palette.base0D}";
      FormPosition = "left";

      ForceHideCompletePassword = true;
    };
  };
in
{
  options.frgd.desktop.addons.sddm = with types; {
    enable = mkBoolOpt false "Whether to enable the gnome file manager.";
  };

  config = mkIf cfg.enable {

    services.displayManager = {
      defaultSession = "hyprland";
      sddm = {
        enable = true;
        package = pkgs.kdePackages.sddm; # qt6 sddm version

        theme = "sddm-astronaut-theme";
        extraPackages = [ sddm-astronaut ];

        wayland.enable = true;
      };
    };

    environment.systemPackages = [ sddm-astronaut ];
  };
}
