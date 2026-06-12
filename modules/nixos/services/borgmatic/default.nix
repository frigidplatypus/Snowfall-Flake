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

  # Per-repository submodule type — allows per-repo SSH keys, passphrases,
  # directories, and labels while keeping backward compatibility with
  # plain-string repositories.
  repositoryType = types.submodule ({ config, ... }: {
    options = {
      path = mkOption {
        type = types.str;
        description = "Repository path, e.g. ssh://user@host/./repo or /mnt/backup/repo.";
      };

      label = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional human-readable label. Auto-derived from path if unset.";
      };

      directories = mkOption {
        type = types.nullOr (types.listOf types.str);
        default = null;
        description = ''
          Directories to back up TO THIS REPOSITORY ONLY.
          Falls back to top-level `directories` if null.
        '';
      };

      # SSH key — per-repo override of the global sshKeySecret
      sshKeySecret = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name of the sops secret containing the SSH private key for THIS repo.
          Overrides the top-level sshKeySecret.  The module auto-declares
          sops.secrets.<name> automatically.
        '';
      };

      # SSH command — explicit override per repo
      sshCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Full SSH command for this repository.
          Takes precedence over both per-repo sshKeySecret and top-level
          sshCommand/sshKeySecret.
        '';
      };

      # Per-repo encryption passphrase secret
      encryption = {
        passphraseSecret = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Name of the sops secret for this repo's Borg passphrase.
            Overrides the top-level encryption.passphraseSecret.
          '';
        };
      };

      encryptionPassCommand = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Explicit passcommand for this repository.
          Takes precedence over all other passphrase settings.
        '';
      };
    };
  });

  # Resolve global SSH command: explicit override wins, then derive from sshKeySecret.
  effectiveSshCommand =
    if cfg.sshCommand != null then
      cfg.sshCommand
    else if cfg.sshKeySecret != null then
      "ssh -i ${config.sops.secrets.${cfg.sshKeySecret}.path}"
    else
      null;

  # Resolve global passcommand: explicit override wins, then derive from passphraseSecret.
  effectivePassCommand =
    if cfg.encryptionPassCommand != null then
      cfg.encryptionPassCommand
    else if cfg.encryption.enable && cfg.encryption.passphraseSecret != null then
      "cat ${config.sops.secrets.${cfg.encryption.passphraseSecret}.path}"
    else
      null;

  # Compute effective per-repository settings, auto-deriving label.
  # Note: per-repo ssh_command, encryption_passcommand, and source_directories
  # are NOT included here because nixpkgs' services.borgmatic.settings
  # repository submodule only accepts path + label.
  effectiveRepositories = map (repo:
    rec {
      inherit (repo) path;

      # Auto-derive label if not set
      label = if repo.label or null != null then repo.label
        else if hasPrefix "ssh://" path then builtins.elemAt (splitString "/" path) 2
        else baseNameOf path;
    }
  ) cfg.repositories;

  # Compute Pushover error command when enabled
  pushoverErrorCmd = lib.optional (cfg.notifications.pushover.enable && cfg.notifications.pushover.onError) {
    after = "error";
    run = [
      ''curl -s -o /dev/null --data-urlencode "token=${lib.escapeShellArg cfg.notifications.pushover.apiToken}" --data-urlencode "user=${lib.escapeShellArg cfg.notifications.pushover.userKey}" --data-urlencode "message=Borg backup FAILED on $(hostname) - check: journalctl -u borgmatic.service -n 50" --data-urlencode "priority=1" --data-urlencode "sound=falling" https://api.pushover.net/1/messages.json''
    ];
  };

  # Global defaults that apply config-wide (SSH, passphrase, retention, compression, checks, hooks)
  globalDefaults = {
    compression = mkIf (cfg.compression != null) cfg.compression;
    ssh_command = mkIf (effectiveSshCommand != null) effectiveSshCommand;
    encryption_passcommand = mkIf (effectivePassCommand != null) effectivePassCommand;

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
      })
      ++ pushoverErrorCmd;
  };

in
{
  options.frgd.services.borgmatic = with types; {
    enable = mkBoolOpt false "Whether or not to enable borgmatic.";

    directories = mkOption {
      type = listOf str;
      default = [ "/var/lib" "/home" ];
      description = "List of directories to back up.";
      example = [
        "/home"
        "/etc"
        "/var/log"
      ];
    };

    repositories = mkOption {
      type = types.listOf (types.either types.str repositoryType);
      default = [ ];
      description = "List of Borg repositories. Each can be a plain URL string or a detailed attrset with per-repo SSH key, passphrase, and directories.";
      example = literalExpression ''
        [
          "ssh://user@host/./repo"
          {
            path = "ssh://user2@host2/./repo";
            label = "critical";
            sshKeySecret = "critical_borg_key";
            directories = [ "/etc" "/root" ];
          }
        ]
      '';
      # Normalise plain strings to attrsets so downstream code always
      # works with the structured format.
      apply = map (repo:
        if builtins.isString repo then { path = repo; }
        else repo
      );
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
        Per-repository sshKeySecret overrides this for individual repos.
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

    notifications = {
      pushover = {
        enable = mkBoolOpt false "Whether to send Pushover notifications on backup failure.";

        apiToken = mkOption {
          type = nullOr str;
          default = null;
          description = "Pushover Application API token.";
        };

        userKey = mkOption {
          type = nullOr str;
          default = null;
          description = "Pushover User Key.";
        };

        onError = mkBoolOpt true "Send notification on backup failure. Requires apiToken and userKey.";
      };

      watchdog = {
        enable = mkBoolOpt false ''
          Enable a systemd timer that alerts if no backup has completed within the
          grace period.  Catches cases where the machine was off, the timer was
          disabled, or borgmatic never ran.
        '';

        gracePeriod = mkOption {
          type = str;
          default = "36h";
          description = "How old the last backup can be before alerting (e.g. 24h, 48h).";
          example = "48h";
        };

        checkInterval = mkOption {
          type = str;
          default = "6h";
          description = "How often to check (e.g. 1h, 6h, 12h).";
          example = "12h";
        };
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
    # Auto-declare sops secrets — collect all unique names from both global
    # and per-repository settings so callers never need manual sops.secrets.*
    # declarations for borg.
    sops.secrets =
      let
        sshSecrets = lib.unique (
          lib.optional (cfg.sshKeySecret != null) cfg.sshKeySecret
          ++ concatMap (repo: lib.optional (repo.sshKeySecret or null != null) repo.sshKeySecret) cfg.repositories
        );
        passSecrets = lib.unique (
          lib.optional (cfg.encryption.enable && cfg.encryption.passphraseSecret != null) cfg.encryption.passphraseSecret
          ++ concatMap (repo: lib.optional (repo.encryption.passphraseSecret or null != null) repo.encryption.passphraseSecret) cfg.repositories
        );
      in
      lib.listToAttrs (map (name: {
        inherit name;
        value = {
          owner = "root";
          mode = "0400";
        };
      }) (sshSecrets ++ passSecrets));

    services.borgmatic = {
      enable = true;

      settings = mkIf (cfg.directories != [ ] || cfg.repositories != [ ]) (recursiveMerge [
        {
          # Top-level source_directories serves as fallback; per-repo
          # source_directories in each repository entry take precedence.
          source_directories = cfg.directories;
          repositories = effectiveRepositories;
        }
        globalDefaults
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

    # Watchdog timer — alerts if no backup completed within the grace period
    # (catches machine-offline, timer-disabled, and silent-failure scenarios
    # that onError hooks would miss).
    systemd.services.borgmatic-watchdog = mkIf cfg.notifications.watchdog.enable {
      description = "Borgmatic backup watchdog — alerts if backup is stale";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "borgmatic-watchdog" ''
          set -euo pipefail

          last_run=$(systemctl show borgmatic.service --property=ActiveEnterTimestamp --value 2>/dev/null || true)
          if [ -z "$last_run" ]; then
            ${pkgs.curl}/bin/curl -s -o /dev/null \
              --data-urlencode "token=${lib.escapeShellArg cfg.notifications.pushover.apiToken}" \
              --data-urlencode "user=${lib.escapeShellArg cfg.notifications.pushover.userKey}" \
              --data-urlencode "message=Borg WATCHDOG: borgmatic has never run on $(hostname)!" \
              --data-urlencode "priority=1" \
              https://api.pushover.net/1/messages.json
            exit 0
          fi

          last_epoch=$(date -d "$last_run" +%s 2>/dev/null || echo "0")
          now_epoch=$(date +%s)
          grace_seconds=$(( 3600 * $(echo "${cfg.notifications.watchdog.gracePeriod}" | sed 's/h//') ))
          age=$(( now_epoch - last_epoch ))

          if [ "$age" -gt "$grace_seconds" ]; then
            ${pkgs.curl}/bin/curl -s -o /dev/null \
              --data-urlencode "token=${lib.escapeShellArg cfg.notifications.pushover.apiToken}" \
              --data-urlencode "user=${lib.escapeShellArg cfg.notifications.pushover.userKey}" \
              --data-urlencode "message=Borg WATCHDOG: $(hostname) backup is stale! Last run: $last_run ($age seconds ago, grace: ${cfg.notifications.watchdog.gracePeriod})" \
              --data-urlencode "priority=1" \
              https://api.pushover.net/1/messages.json
          fi
        '';
      };
    };

    systemd.timers.borgmatic-watchdog = mkIf cfg.notifications.watchdog.enable {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* ${cfg.notifications.watchdog.checkInterval}:00:00";
        Persistent = true;
        RandomizedDelaySec = "15m";
      };
    };
  };
}
