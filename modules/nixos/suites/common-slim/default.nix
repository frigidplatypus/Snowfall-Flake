{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.suites.common-slim;
in {
  options.frgd.suites.common-slim = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable common-slim configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ snowfallorg.flake ];
    frgd = {
      nix = enabled;

      tools = {
        git = enabled;
        comma = enabled;
        direnv = enabled;
        misc = enabled;
      };

      hardware = {
        # storage = enabled;
        networking = enabled;
      };

      services = {
        openssh = enabled;
        tailscale = enabled;
        avahi = enabled;
        syncthing = enabled;
      };

      # security = { doas = enabled; };

      system = {
        boot = enabled;
        fonts = enabled;
        locale = enabled;
        time = enabled;
        xkb = enabled;
      };
    };
  };
}
