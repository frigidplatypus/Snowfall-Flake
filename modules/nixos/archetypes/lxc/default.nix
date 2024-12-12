{
  config,
  lib,
  modulesPath,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.archetypes.lxc;
in
{
  options.frgd.archetypes.lxc = with types; {
    enable = mkBoolOpt false "Whether or not to enable the virtual machine archetype.";
  };

  config = mkIf cfg.enable {
    boot.isContainer = true;
    systemd.suppressedSystemUnits = [
      "dev-mqueue.mount"
      "sys-kernel-debug.mount"
      "sys-fs-fuse-connections.mount"
    ];
    frgd = {
      nix = enabled;

      cli-apps = {
        nh = enabled;
      };
      services = {
        openssh = enabled;
        tailscale = {
          enable = true;
          autoconnect = enabled;
        };
      };
      security = {
        sops = enabled;
        doas = enabled;
      };
      system = {
        locale = enabled;
        time = enabled;
        xkb = enabled;
      };
    };
  };
}
