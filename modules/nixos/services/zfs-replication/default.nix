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

      notification = mkOpt (submodule {
        options = {
          enable = mkBoolOpt false "Enable ntfy.sh notifications on failure";
          topic = mkOption {
            type = types.str;
            default = "";
            description = "ntfy.sh topic to send notifications to (required if notification is enabled)";
          };
          url = mkOpt str "https://ntfy.sh" "ntfy.sh server URL";
          title = mkOpt str "Syncoid Failure" "Notification title";
          priority = mkOpt str "default" "ntfy.sh priority (default, high, etc)";
        };
        config = mkIf (config.enable && config.topic == "") {
          assertions = [
            {
              assertion = false;
              message = "frgd.services.zfs-replication.syncoid.notification.topic must be set if notification is enabled.";
            }
          ];
        };
      }) { } "Notification options for syncoid failures.";

      systemd = mkOpt (submodule {
        options = {
          enable = mkBoolOpt false "Enable systemd service/timer for syncoid replication.";
          timerOnCalendar = mkOpt str "hourly" "systemd timer OnCalendar value (e.g. hourly, daily, etc)";
        };
      }) { } "Systemd integration for syncoid replication.";
    };
  };

  config =
    let
      syncoidSystemdEnabled = cfg.syncoid.systemd.enable && cfg.syncoid.enable;
      notifyEnabled = cfg.syncoid.notification.enable && cfg.syncoid.notification.topic != "";
    in
    {
      environment.systemPackages = mkIf (cfg.sanoid.enable || cfg.syncoid.enable) (
        with pkgs;
        [
          sanoid
          lzo
          lzop
          mbuffer
          pv
          curl
        ]
      );

      services.sanoid = mkIf cfg.sanoid.enable {
        enable = true;
        templates = cfg.sanoid.templates;
        datasets = lib.mapAttrs (name: val: { useTemplate = [ val ]; }) cfg.sanoid.datasets;
      };

      services.syncoid = mkIf cfg.syncoid.enable {
        enable = true;
        interval = cfg.syncoid.interval;
        user = cfg.syncoid.user;
        sshKey = useSshKey cfg.syncoid.sshKey;
        commands = lib.mapAttrs (
          name: cmd:
          cmd
          // {
            sshKey = useSshKey cmd.sshKey;
          }
        ) cfg.syncoid.commands;
      };

      systemd.services.syncoid-replication = mkIf syncoidSystemdEnabled {
        description = "ZFS Syncoid Replication with ntfy.sh notification on failure";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = cfg.syncoid.user;
        };
        script =
          let
            syncoidCommands = lib.mapAttrsToList (name: cmd: ''
              echo "Running syncoid for ${name}: ${cmd.source} -> ${cmd.target}"
              ERROR_LOG=$(mktemp)
              if ! syncoid "${cmd.source}" "${cmd.target}" 2> "$ERROR_LOG"; then
                ERROR_MSG=$(cat "$ERROR_LOG")
                ${
                  if notifyEnabled then
                    ''
                      ${pkgs.curl}/bin/curl -X POST \
                        -H "Title: ${cfg.syncoid.notification.title}" \
                        -H "Priority: ${cfg.syncoid.notification.priority}" \
                        -d "Syncoid replication failed for ${name}!\nSource: ${cmd.source}\nTarget: ${cmd.target}\nHost: $(hostname)\nError:\n$ERROR_MSG" \
                        "${cfg.syncoid.notification.url}/${cfg.syncoid.notification.topic}"
                    ''
                  else
                    ""
                }
                exit 1
              fi
              rm "$ERROR_LOG"
            '') cfg.syncoid.commands;
            notifyCmd =
              if notifyEnabled then
                ''
                  ${pkgs.curl}/bin/curl -X POST \
                    -H "Title: ${cfg.syncoid.notification.title}" \
                    -H "Priority: ${cfg.syncoid.notification.priority}" \
                    -d "Syncoid replication failed!\nSource: $SRC\nTarget: $DST\nHost: $(hostname)\nError:\n$ERROR_MSG" \
                    "${cfg.syncoid.notification.url}/${cfg.syncoid.notification.topic}"
                ''
              else
                "";
          in
          ''
            set -e
            ${lib.concatStringsSep "\n" syncoidCommands}
          '';
      };

      systemd.timers.syncoid-replication = mkIf syncoidSystemdEnabled {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.syncoid.systemd.timerOnCalendar;
          Persistent = true;
        };
        unitConfig = {
          Description = "Run syncoid replication with notification on failure";
        };
      };
    };
}
