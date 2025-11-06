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
    services.getty.autologinUser = "root";
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "cpu"
        "meminfo"
        "loadavg"
        "filesystem"
        "netdev"
        "tcpstat"
        "softirqs"
        "processes"
        "textfile"
        "systemd"
      ];
      # Only add ethtool/wifi/systemd if you intentionally give the container extra access:
      # enabledCollectors = lib.optional st.systemdRunning "systemd" ++ ...
    };

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
