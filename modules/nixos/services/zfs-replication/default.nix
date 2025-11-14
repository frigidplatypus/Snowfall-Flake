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
  useSshKey = key: if config.services.tailscale.enable then null else key;
in
{
  options.frgd.services.zfs-replication = with types; {
    enable = mkBoolOpt false "Whether or not to enable ZFS replication.";

    datasets = mkOpt (attrsOf (submodule {
      options = {
        source = mkOpt str "" "Source dataset.";
        target = mkOpt str "" "Target dataset (user@host:pool/dataset).";
        recursive = mkBoolOpt true "Whether to replicate recursively.";
        template = mkOpt str "default" "Sanoid template to use for snapshots.";
      };
    })) { } "ZFS datasets to replicate with sanoid snapshots and syncoid replication.";

    sanoid = {
      enable = mkBoolOpt true "Whether or not to enable sanoid snapshots.";

      templates =
        mkOpt (attrsOf (attrsOf (either str (either bool int)))) { }
          "Sanoid templates for snapshot policies (supports strings, booleans, and integers for options like hourly, autosnap, etc.).";

      datasets =
        mkOpt (attrsOf str) { }
          "Dataset-specific sanoid configurations (values are template names, e.g., { zroot = \"default\"; }).";
    };

    syncoid = {
      enable = mkBoolOpt false "Whether or not to enable syncoid replications.";

      interval = mkOpt str "daily" "Schedule for syncoid runs.";

      user = mkOpt str "root" "User to run syncoid as.";

      sshKey = mkOpt (nullOr str) null "Global SSH key.";

      commands = mkOpt (attrsOf (submodule {
        options = {
          source = mkOpt str "" "Source dataset.";
          target = mkOpt str "" "Target dataset.";
          recursive = mkBoolOpt true "Whether to replicate recursively.";
          sshKey = mkOpt (nullOr str) null "SSH key for this command.";
        };
      })) { } "Syncoid commands.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sanoid
      lzo
      lzop
      mbuffer
      pv
      curl
    ];

    # Generate sanoid configuration from datasets
    services.sanoid = {
      enable = true;
      templates = cfg.sanoid.templates;
      datasets = lib.mapAttrs' (name: dataset: {
        name = dataset.source;
        value = {
          template = dataset.template;
        };
      }) cfg.datasets;
    };

    # Generate syncoid configuration from datasets
    services.syncoid = {
      enable = true;
      interval = cfg.syncoid.interval;
      user = "root"; # Run as root to have ZFS permissions, use SSH key for remote auth
      sshKey = useSshKey cfg.syncoid.sshKey;
      commonArgs = [ "--no-sync-snap" ]; # Use sanoid snapshots instead of creating syncoid snapshots
      commands = lib.mapAttrs' (name: dataset: {
        name = name;
        value = {
          source = dataset.source;
          target = dataset.target;
          recursive = dataset.recursive;
          sshKey = cfg.syncoid.sshKey;
        };
      }) cfg.datasets;
    };
  };

}
