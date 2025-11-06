{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.system.zfs;
in
{
  options.frgd.system.zfs = with types; {
    enable = mkBoolOpt false "Whether or not to enable ZFS support.";

    pools = mkOpt (listOf str) [ "zpool" ] "The ZFS pools to manage.";

    auto-snapshot = {
      enable = mkBoolOpt false "Whether or not to enable ZFS auto snapshotting.";
    };

    hostID = mkOpt str "00000000" "The host ID to use for ZFS auto snapshotting.";

  };

  config = mkIf cfg.enable {
    boot.supportedFilesystems = [ "zfs" ];
    environment.systemPackages = with pkgs; [
      zfs
      lzo
      pv
      mbuffer
    ];
    services.prometheus.exporters.zfs = enabled;
    services.zfs = {
      autoScrub = {
        enable = true;
        pools = cfg.pools;
      };

      autoSnapshot = mkIf cfg.auto-snapshot.enable {
        enable = true;
        flags = "-k -p --utc";
        weekly = mkDefault 3;
        daily = mkDefault 3;
        hourly = mkDefault 0;
        frequent = mkDefault 0;
        monthly = mkDefault 2;
      };
    };
    frgd.tools.sanoid = enabled;
  };
}
