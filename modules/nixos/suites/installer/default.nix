{
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.suites.installer;
in
{
  options.frgd.suites.installer = with types; {
    enable = mkBoolOpt false "Whether or not to enable installer configuration.";
  };

  config = mkIf cfg.enable {

    security.sudo = enabled;
    frgd = {
      nix = enabled;

      services = {
        openssh = enabled;
        #        tailscale = enabled;
        avahi = enabled;
        #       syncthing = enabled;
      };
    };
  };
}
