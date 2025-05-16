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

  # Default settings that apply to all configurations
  defaultSettings = {
    # Standard Borg settings
    compression = mkIf (cfg.compression != null) cfg.compression;
    encryption_passcommand = mkIf (cfg.encryptionPassCommand != null) cfg.encryptionPassCommand;
    ssh_command = mkIf (cfg.sshCommand != null) cfg.sshCommand;

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

    # Hooks
    before_backup = mkIf (cfg.hooks.beforeBackup != [ ]) cfg.hooks.beforeBackup;
    after_backup = mkIf (cfg.hooks.afterBackup != [ ]) cfg.hooks.afterBackup;
    on_error = mkIf (cfg.hooks.onError != [ ]) cfg.hooks.onError;
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

    # Basic configuration options
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

    # Advanced configuration
    compression = mkOption {
      type = nullOr str;
      default = "auto,lzma";
      description = "Compression algorithm to use.";
      example = "lz4";
    };

    encryptionPassCommand = mkOption {
      type = nullOr str;
      default = null;
      description = "Command to get the encryption password.";
      example = "cat /etc/borgmatic/passphrase";
    };

    sshCommand = mkOption {
      type = nullOr str;
      default = null;
      description = "Custom SSH command for remote repositories.";
      example = "ssh -i /etc/borgmatic/id_ed25519 -p 2222";
    };

    # Scheduling options
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

    # Retention policies
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

    # Pre/post hooks
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

    # Advanced: custom configurations
    extraConfig = mkOption {
      type = attrsOf anything;
      default = { };
      description = "Extra configuration options to pass to borgmatic.";
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
    # Set up the upstream borgmatic service
    services.borgmatic = {
      enable = true;

      # Generate the main configuration if basic options are provided
      settings = mkIf (cfg.directories != [ ] && cfg.repositories != [ ]) (recursiveMerge [
        basicConfig
        defaultSettings
        cfg.extraConfig
      ]);

      # Add any extra configurations
      configurations = cfg.extraConfigurations;
    };

    # Install borgmatic package
    environment.systemPackages = [ pkgs.borgmatic ];

    # Custom systemd timer if custom scheduling is enabled
    systemd.timers.borgmatic = mkIf cfg.schedule.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "${cfg.schedule.frequency} *-*-* ${cfg.schedule.time}";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
