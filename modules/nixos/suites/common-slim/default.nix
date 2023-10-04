{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.suites.common-slim;
in
{
  options.frgd.suites.common-slim = with types; {
    enable = mkBoolOpt false "Whether or not to enable common-slim configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      # pkgs.frgd.list-iommu
    ];

    frgd = {
      nix = enabled;

      # @TODO(jakehamilton): Enable this once Attic is configured again.
      # cache.public = enabled;

      cli-apps = {
        # flake = enabled;
      };

      tools = {
        git = enabled;
        fup-repl = enabled;
        comma = enabled;
        btop = enabled;
        direnv = enabled;
        misc = enabled;
      };

      hardware = {
        storage = enabled;
        networking = enabled;
      };

      services = {
        openssh = enabled;
        tailscale = enabled;
      };

      security = {
        # doas = enabled;
      };

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
