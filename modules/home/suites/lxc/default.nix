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
  cfg = config.frgd.suites.lxc;
in
{
  options.frgd.suites.lxc = with types; {
    enable = mkBoolOpt false "Whether or not to enable the common suite of home-manager packages.";
  };

  config = mkIf cfg.enable {
    frgd = {
      cli-apps = {
        zoxide = mkForce disabled;
        neovim = mkForce disabled;
        home-manager = enabled;
        ranger = mkForce disabled;
        fish = mkForce disabled;
      };

      tools = {
        git = enabled;
        lsd = enabled;
      };
    };
  };
}
