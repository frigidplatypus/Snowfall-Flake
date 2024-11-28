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
  cfg = config.frgd.suites.common;
in
{
  options.frgd.suites.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable the common suite of home-manager packages.";
  };

  config = mkIf cfg.enable {
    frgd = {
      cli-apps = {
        zoxide = enabled;
        neovim = enabled;
        home-manager = enabled;
        ranger = enabled;
        fish = enabled;
      };

      tools = {
        git = enabled;
        ssh = enabled;
        lsd = enabled;
      };
    };
  };
}
