{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.opencode;
  
  opencodeConfig = pkgs.formats.json { };
  
  configFile = opencodeConfig.generate "opencode.json" cfg.settings;
in
{
  options.frgd.cli-apps.opencode = with types; {
    enable = mkBoolOpt false "Whether or not to enable OpenCode.";
    package = mkOpt types.package pkgs.opencode "The OpenCode package to use.";
    settings = mkOpt (attrsOf anything) {} "OpenCode configuration settings.";
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."opencode/opencode.json".source = configFile;
  };
}