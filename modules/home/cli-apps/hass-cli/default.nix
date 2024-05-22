{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.frgd) enabled;

  cfg = config.frgd.cli-apps.hass-cli;
in
{
  options.frgd.cli-apps.hass-cli = {
    enable = mkEnableOption "hass-cli";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ home-assistant-cli ];
    home.sessionVariables = {
      HASS_SERVER = "https://ha.frgd.us";
    };
  };
}
