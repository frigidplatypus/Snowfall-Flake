{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.suites.common;
in
{
  options.frgd.suites.common = with types; {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.frgd.list-iommu
    ];

    frgd = {
      nix = enabled;

      # @TODO(jakehamilton): Enable this once Attic is configured again.
      # cache.public = enabled;

      cli-apps = {
        flake = enabled;
      };

      tools = {
        git = enabled;
        misc = enabled;
        # fup-repl = enabled;
        comma = enabled;
        # nix-ld = enabled;
        btop = enabled;
      };

      hardware = {
        audio = enabled;
        storage = enabled;
        networking = enabled;
      };

      services = {
        printing = enabled;
        openssh = enabled;
        tailscale = enabled;
      };

      security = {
        gpg = enabled;
        doas = enabled;
        keyring = enabled;
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
