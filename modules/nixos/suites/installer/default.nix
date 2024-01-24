{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.suites.installer;
in {
  options.frgd.suites.installer = with types; {
    enable =
      mkBoolOpt false "Whether or not to enable installer configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      snowfallorg.flake
      gcc
      neovim
      nixfmt
      ripgrep
    ];

    security.sudo = enabled;
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
        # networking = enabled;
      };

      services = {
        openssh = enabled;
        #        tailscale = enabled;
        avahi = enabled;
        #       syncthing = enabled;
      };
    };
  };
}
