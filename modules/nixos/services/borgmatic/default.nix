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
  cfg = config.frgd.services.borgmatic;

  # Helper function to merge config sets
  recursiveMerge =
    attrList:
    let
      merger = attrs: foldl' (recursiveUpdate) { } attrs;
    in
    merger attrList;

  # Resolve SSH command: explicit override wins, then derive from sshKeySecret.
  effectiveSshCommand =
    if cfg.sshCommand != null then
      cfg.sshCommand
    else if cfg.sshKeySecret != null then
      "ssh -i ${config.sops.secrets.${cfg.sshKeySecret}.path}"
    else
      null;

  # Resolve passcommand: explicit override wins, then derive from passphraseSecret.
  effectivePassCommand =
    if cfg.encryptionPassCommand != null then
      cfg.encryptionPassCommand
    else if cfg.encryption.enable && cfg.encryption.passphraseSecret != null then
      "cat ${config.sops.secrets.${cfg.encryption.passphraseSecret}.path}"
    else
      null;

  # Default settings that apply to all configurations
  defaultSettings = {
    compression = mkIf (cfg.compression != null) cfg.compression;
    encryption_passcommand = mkIf (effectivePassCommand != null) effectivePassCommand;
    ssh_command = mkIf (effectiveSshCommand != null) effectiveSshCommand;

    # Consistency and validation
    checks = [
      {
        name = "repository";
        frequency = "3 weeks";
      }
      {
        name = "archives";
        frequency = "3 weeks";
      }
    ];

    # Retention policy (if enabled)
    keep_daily = mkIf cfg.retention.enable cfg.retention.keepDaily;
    keep_weekly = mkIf cfg.retention.enable cfg.retention.keepWeekly;
    keep_monthly = mkIf cfg.retention.enable cfg.retention.keepMonthly;
    keep_yearly = mkIf cfg.retention.enable cfg.retention.keepYearly;

    # Hooks — borgmatic 2.0.0+ `commands:` format
    commands =
      (lib.optional (cfg.hooks.beforeBackup != [ ]) {
        before = "action";
        when = [ "create" ];
        run = cfg.hooks.beforeBackup;
      })
      ++ (lib.optional (cfg.hooks.afterBackup != [ ]) {
        after = "action";
        when = [ "create" ];
        run = cfg.hooks.afterBackup;
      })
      ++ (lib.optional (cfg.hooks.onError != [ ]) {
        after = "error";
        run = cfg.hooks.onError;
      });
  };

  # Basic configuration for simple setups
  basicConfig = {
    source_directories = cfg.directories;
    repositories = map (repo: {
      path = repo;
      label =
        if hasPrefix "ssh://" repo then builtins.elemAt (splitString "/" repo) 2 else baseNameOf repo;
    }) cfg.repositories;
  };

in
{
  options.frgd.services.borgmatic = with types; {
    enable = mkBoolOpt false "Whether or not to enable borgmatic.";

    directories = mkOption {
      type = listOf str;
      default = [ ];
      description = "List of directories to back up.";
      example = [
        "/home"
        "/etc"
        "/var/log"
      ];
    };

    repositories = mkOption {
      type = listOf str;
      default = [ ];
      description = "List of repository paths to back up to.";
      example = [
        "ssh://user@backupserver/./backup.borg"
        "/mnt/external/backup.borg"
      ];
    };

    # SSH — resolved from a sops secret by default.
    # The module auto-declares sops.secrets.<sshKeySecret>; no manual declaration needed.
    # Set sshCommand to override the derived command entirely.
    sshKeySecret = mkOption {
      type = nullOr str;
      default = "borg_ssh_key";
      description = ''
        Name of the sops secret containing the Borg SSH private key.
        The module declares sops.secrets.<name> automatically and derives
        ssh_command from its runtime path.  Set to null to disable.
      '';
    };

    sshCommand = mkOption {
      type = nullOr str;
      default = null;
      description = "Override the SSH command.  Takes precedence over sshKeySecret.";
      example = "ssh -i /etc/borgmatic/id_ed25519 -p 2222";
    };

    # Encryption — enabled by default using repokey-blake2 + borg_passphrase secret.
    # New repos must be initialised with: borgmatic rcreate --encryption repokey-blake2
    encryption = {
      enable = mkBoolOpt true "Enable passphrase-based encryption.";

      mode = mkOption {
        type = str;
        default = "repokey-blake2";
        description = ''
          Borg encryption mode used when initialising a new repository
          (borgmatic rcreate --encryption <mode>).  Not written to the
          borgmatic config — borg stores the mode inside the repo itself.
        '';
      };

      passphraseSecret = mkOption {
        type = nullOr str;
        default = "borg_passphrase";
        description = ''
          Name of the sops secret containing the Borg passphrase.
          The module declares sops.secrets.<name> automatically and sets
          encryption_passcommand to read from its runtime path.  Set to null to disable.
        '';
      };
    };

    encryptionPassCommand = mkOption {
      type = nullOr str;
      default = null;
      description = "Override the passcommand.  Takes precedence over encryption.passphraseSecret.";
      example = "cat /etc/borgmatic/passphrase";
    };

    compression = mkOption {
      type = nullOr str;
      default = "auto,lzma";
      description = "Compression algorithm to use.";
      example = "lz4";
    };

    schedule = {
      enable = mkBoolOpt true "Whether to enable scheduled backups.";

      time = mkOption {
        type = str;
        default = "04:00:00";
        description = "Time to run the backup (HH:MM:SS format).";
      };

      frequency = mkOption {
        type = str;
        default = "daily";
        description = "How often to run the backup (daily, weekly, etc.).";
        example = "weekly";
      };
    };

    retention = {
      enable = mkBoolOpt true "Whether to enable retention policies.";

      keepDaily = mkOption {
        type = int;
        default = 7;
        description = "Number of daily archives to keep.";
      };

      keepWeekly = mkOption {
        type = int;
        default = 4;
        description = "Number of weekly archives to keep.";
      };

      keepMonthly = mkOption {
        type = int;
        default = 6;
        description = "Number of monthly archives to keep.";
      };

      keepYearly = mkOption {
        type = int;
        default = 1;
        description = "Number of yearly archives to keep.";
      };
    };

    hooks = {
      beforeBackup = mkOption {
        type = listOf str;
        default = [ ];
        description = "Commands to run before backup.";
        example = [ "echo 'Starting backup'" ];
      };

      afterBackup = mkOption {
        type = listOf str;
        default = [ ];
        description = "Commands to run after backup.";
        example = [ "echo 'Backup complete'" ];
      };

      onError = mkOption {
        type = listOf str;
        default = [ ];
        description = "Commands to run when a backup fails.";
        example = [ "echo 'Backup failed' | mail -s 'Backup error' admin@example.com" ];
      };
    };

    # Automatic repository initialisation
    # Runs borgmatic rcreate once before the first backup, then never again
    # (sentinel file at /var/lib/borgmatic/.initialized guards against re-runs).
    # Delete the sentinel to force re-initialisation.
    autoInit = {
      enable = mkBoolOpt false ''
        Automatically initialise Borg repositories before the first backup.
        A oneshot systemd service runs borgmatic rcreate --encryption <mode>
        exactly once.  Subsequent boots skip it via a sentinel file.
        Requires encryption.enable = true.
      '';
    };

    extraConfig = mkOption {
      type = attrsOf anything;
      default = { };
      description = "Extra borgmatic settings merged into the main configuration.";
    };

    extraConfigurations = mkOption {
      type = attrsOf (attrsOf anything);
      default = { };
      description = "Additional named borgmatic configurations.";
      example = literalExpression ''
        {
          critical = {
            source_directories = [ "/etc" "/root" ];
            repositories = [ { path = "/mnt/backup/critical"; label = "critical"; } ];
            keep_daily = 14;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    # Auto-declare sops secrets — callers never need manual sops.secrets.* for borg.
    sops.secrets =
      (lib.optionalAttrs (cfg.sshKeySecret != null) {
        ${cfg.sshKeySecret} = {
          owner = "root";
          mode = "0400";
        };
      })
      // (lib.optionalAttrs (cfg.encryption.enable && cfg.encryption.passphraseSecret != null) {
        ${cfg.encryption.passphraseSecret} = {
          owner = "root";
          mode = "0400";
        };
      });

    services.borgmatic = {
      enable = true;

      settings = mkIf (cfg.directories != [ ] && cfg.repositories != [ ]) (recursiveMerge [
        basicConfig
        defaultSettings
        cfg.extraConfig
      ]);

      configurations = cfg.extraConfigurations;
    };

    environment.systemPackages = [ pkgs.borgmatic ];

    systemd.timers.borgmatic = mkIf cfg.schedule.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        # Map plain-English frequency aliases to the correct systemd calendar
        # expression prefix.  If the user passes a weekday or other value not
        # in this map it is forwarded verbatim (e.g. "Mon", "Sat,Sun").
        OnCalendar =
          let
            prefixMap = {
              daily = "*-*-*";
              weekly = "Mon *-*-*";
              monthly = "*-*-01";
              yearly = "*-01-01";
            };
            prefix = prefixMap.${cfg.schedule.frequency} or "${cfg.schedule.frequency} *-*-*";
          in
          "${prefix} ${cfg.schedule.time}";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };

    # One-shot service that initialises repositories before the first backup.
    # Guarded by a sentinel file so it only runs once per host.
    systemd.services.borgmatic-init = mkIf cfg.autoInit.enable {
      description = "Initialise Borg repositories (runs once)";
      wantedBy = [ "borgmatic.service" ];
      before = [ "borgmatic.service" ];
      after = [
        "network-online.target"
        "sops-install-secrets.service"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "borgmatic-init" ''
          set -euo pipefail
          sentinel="/var/lib/borgmatic/.initialized"
          if [ -f "$sentinel" ]; then
            echo "borgmatic-init: already initialised, skipping"
            exit 0
          fi
          echo "borgmatic-init: initialising repositories (${cfg.encryption.mode})"
          ${pkgs.borgmatic}/bin/borgmatic rcreate --encryption ${lib.escapeShellArg cfg.encryption.mode}
          mkdir -p "$(dirname "$sentinel")"
          touch "$sentinel"
          echo "borgmatic-init: done — remember to export and store the repo key"
        '';
      };
    };
  };
}
