{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.hass-cli;
in
{
  options.frgd.cli-apps.hass-cli = with types; {
    enable = mkBoolOpt false "Whether or not to enable hass-cli.";
    serverUrl = mkOpt str "https://ha.frgd.us" "The Home Assistant server URL.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ home-assistant-cli ];
    home.sessionVariables = {
      HASS_SERVER = cfg.serverUrl;
    };
  };
}
