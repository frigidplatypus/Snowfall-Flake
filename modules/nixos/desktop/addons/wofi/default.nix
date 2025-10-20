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
  cfg = config.frgd.desktop.addons.wofi;
in
{
  options.frgd.desktop.addons.wofi = with types; {
    enable = mkBoolOpt false "Whether to enable the Wofi in the desktop environment.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wofi
      wofi-emoji
    ];

    # config -> .config/wofi/config
    # css -> .config/wofi/style.css
    # colors -> $XDG_CACHE_HOME/wal/colors
    # frgd.home.configFile."foot/foot.ini".source = ./foot.ini;
    frgd.home.configFile."wofi/config".source = ./config;
    frgd.home.configFile."wofi/style.css".source = ./style.css;
  };
}
