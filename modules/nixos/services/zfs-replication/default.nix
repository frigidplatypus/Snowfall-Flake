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
  cfg = config.frgd.services.zfs-replication;
  # When Tailscale is enabled on the host, syncoid authenticates over the
  # tailnet (Tailscale SSH), so no explicit key is needed. Otherwise fall
  # back to the configured SSH key.
  useSshKey = key: if config.services.tailscale.enable then null else key;
in
{
  options.frgd.services.zfs-replication = with types; {
    enable = mkBoolOpt false "Whether or not to enable ZFS replication.";

    sanoid = {
      enable = mkBoolOpt true "Whether or not to enable sanoid snapshots.";

      templates =
        mkOpt (attrsOf (attrsOf (either str (either bool int)))) { }
          "Sanoid templates for snapshot policies (supports strings, booleans, and integers for options like hourly, autosnap, etc.).";

      datasets =
        mkOpt (attrsOf str) { }
          "Datasets to snapshot (name -> template). Snapshots are taken recursively, so a parent template also covers child datasets.";
    };

    syncoid = {
      enable = mkBoolOpt false "Whether or not to enable syncoid replications.";

      interval = mkOpt str "daily" "Schedule for syncoid runs (systemd.time(7)).";

      sshKey = mkOpt (nullOr str) null "Global SSH key (ignored when Tailscale is enabled).";

      commands = mkOpt (attrsOf (submodule {
        options = {
          source = mkOpt str "" "Source dataset.";
          target = mkOpt str "" "Target dataset (user@host:pool/dataset).";
          recursive = mkBoolOpt true "Whether to replicate recursively.";
          sshKey = mkOpt (nullOr str) null "SSH key for this command (defaults to global).";
        };
      })) { } "Syncoid replication commands (name -> { source, target, recursive }).";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sanoid
      lzo
      lzop
      mbuffer
      pv
    ];

    # Local snapshot policy.
    services.sanoid = {
      enable = cfg.sanoid.enable;
      templates = cfg.sanoid.templates;
      datasets = lib.mapAttrs (dataset: template: {
        use_template = [ template ];
        recursive = true;
      }) cfg.sanoid.datasets;
    };

    # Push snapshots to remote targets.
    services.syncoid = {
      enable = cfg.syncoid.enable;
      interval = cfg.syncoid.interval;
      # Run as root to avoid per-dataset `zfs allow` delegation on the
      # source; remote auth is via Tailscale SSH (or the configured key).
      user = "root";
      sshKey = useSshKey cfg.syncoid.sshKey;
      # Reuse sanoid's snapshots instead of creating throwaway sync snaps.
      commonArgs = [ "--no-sync-snap" ];
      commands = lib.mapAttrs (name: c: {
        source = c.source;
        target = c.target;
        recursive = c.recursive;
        sshKey = useSshKey c.sshKey;
      }) cfg.syncoid.commands;
    };
  };
}
