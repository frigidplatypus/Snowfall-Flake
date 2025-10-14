{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  accountDefaults = {
    gmail = {
      email = "jus10mar10@gmail.com";
      calendarColor = "light blue";
      syncMail = true;
    };
    jk = {
      email = "justin@justinandkathryn.com";
      calendarColor = "light green";
      syncMail = true;
    };
    icloud = {
      email = "justin@icloud.com";
      calendarColor = "yellow";
      syncMail = false;
      caldavUrl = "https://caldav.icloud.com/";
      carddavUrl = "https://contacts.icloud.com/";
      appPasswordSecret = "apple_app_password";
    };
  };

  cfg = config.frgd.cli-apps.pim;
in
{
  options.frgd.cli-apps.pim =
    with types;
    let
      accountModule = types.submodule (
        { name, ... }:
        let
          defaults = lib.attrByPath [ name ] { } accountDefaults;
          defaultEmail = lib.attrByPath [ "email" ] "" defaults;
          defaultColor = lib.attrByPath [ "calendarColor" ] "light blue" defaults;
          defaultAppPasswordSecret = lib.attrByPath [ "appPasswordSecret" ] "${name}_app_password" defaults;
          defaultCaldavUrl = lib.attrByPath [ "caldavUrl" ] null defaults;
          defaultCarddavUrl = lib.attrByPath [ "carddavUrl" ] null defaults;
          defaultCalendarUser = lib.attrByPath [ "calendarUser" ] null defaults;
          defaultContactsUser = lib.attrByPath [ "contactsUser" ] null defaults;
          defaultSyncMail = lib.attrByPath [ "syncMail" ] true defaults;
        in
        {
          options = {
            enable = mkBoolOpt true "Enable this account.";
            email = mkOpt str defaultEmail "Email address for the account.";
            realName = mkOpt str "Justin Martin" "Display name used by mail clients.";
            primary = mkBoolOpt false "Set as the primary account.";
            primaryCollection =
              mkOpt (nullOr str) null
                "Name of the primary collection on the remote (defaults to server default).";
            appPasswordSecret =
              mkOpt str defaultAppPasswordSecret
                "Name of the SOPS secret containing the app password.";
            imapFlavor = mkOpt str "gmail.com" "home-manager IMAP/SMTP flavor (e.g., gmail.com).";
            syncMail = mkBoolOpt defaultSyncMail "Synchronize email for this account.";
            syncCalendar = mkBoolOpt true "Synchronize calendars for this account.";
            calendarColor = mkOpt str defaultColor "Calendar color as rendered in khal.";
            caldavUrl =
              mkOpt (nullOr str) defaultCaldavUrl
                "Override the CalDAV URL; defaults to Google if unset.";
            calendarUser =
              mkOpt (nullOr str) defaultCalendarUser
                "Override the CalDAV username; defaults to the account email.";
            syncContacts = mkBoolOpt true "Synchronize contacts for this account.";
            carddavUrl =
              mkOpt (nullOr str) defaultCarddavUrl
                "Override the CardDAV URL; defaults to Google if unset.";
            contactsUser =
              mkOpt (nullOr str) defaultContactsUser
                "Override the CardDAV username; defaults to the account email.";
            # Comma-separated list of folders to expose in aerc for this account
            folders =
              mkOpt (nullOr str) null
                "Comma-separated list of folders to show in aerc for this account.";
            # Additional CalDAV collection identifiers (UUIDs or names) to
            # sync for this account. If provided these will be appended after
            # `primaryCollection` when generating vdirsyncer collections.
            collections = mkOpt (nullOr (
              listOf str
            )) null "List of additional CalDAV collection ids or names to sync.";
          };
        }
      );
    in
    {
      enable = mkBoolOpt false "Personal Information Management suite (email, calendar, contacts)";
      accounts = mkOpt (attrsOf accountModule) {
        gmail = {
          enable = false;
          email = "jus10mar10@gmail.com";
          primary = true;
          calendarColor = "light blue";
          syncMail = true;
        };
        jk = {
          enable = false;
          email = "justin@justinandkathryn.com";
          calendarColor = "light green";
          syncMail = true;
        };
        icloud = {
          enable = false;
          email = "justin@icloud.com";
          calendarColor = "light yellow";
          syncMail = false;
          caldavUrl = "https://caldav.icloud.com/";
          carddavUrl = "https://contacts.icloud.com/";
          appPasswordSecret = "apple_app_password";
        };
      } "Account definitions keyed by name.";

      calendar = {
        enable = mkBoolOpt true "Enable calendar client (khal)";
        settings = mkOpt attrs { } "Additional khal configuration settings";
      };

      contacts = {
        enable = mkBoolOpt true "Enable contact management (khard)";
      };
    };

  config = mkIf cfg.enable (
    let
      # Filter down to user-enabled accounts so we only render active entries.
      enabledAccounts = filterAttrs (_: acc: acc.enable) cfg.accounts;

      # Convenience list representation for iteration.
      accountList = attrsToList enabledAccounts;

      # Declare SOPS secrets for each account's application password.
      sopsSecrets = listToAttrs (
        map (account: nameValuePair account.value.appPasswordSecret { }) accountList
      );

      # Resolve the decrypted secret path for a given account.
      getSecretPath = acc: config.sops.secrets.${acc.appPasswordSecret}.path;

      # Default Google endpoints used when custom URLs are not provided.
      defaultCaldavUrl = email: "https://apidata.googleusercontent.com/caldav/v2/${email}/events";
      defaultCarddavUrl =
        email: "https://www.googleapis.com/carddav/v1/principals/${email}/lists/default/";

      # Mail account definitions fed into the Home Manager email module.
      emailAccounts = mapAttrs (
        _: acc:
        (
          let
            base = {
              realName = acc.realName;
              address = acc.email;
              flavor = acc.imapFlavor;
              aerc = {
                enable = true;
                extraAccounts = {
                  default = "INBOX";
                };
              };
              primary = acc.primary;
              passwordCommand = "cat ${config.sops.secrets.${acc.appPasswordSecret}.path}";
            };
          in
          base
        )
      ) (filterAttrs (_: acc: acc.syncMail) enabledAccounts);

      # Build calendar sources for khal/vdirsyncer.
      calendarAccounts = listToAttrs (
        concatMap (
          account:
          let
            name = account.name;
            acc = account.value;
            passwordCommand = [
              "cat"
              (getSecretPath acc)
            ];
          in
          optional acc.syncCalendar (
            nameValuePair name {
              primary = acc.primary;
              # Don't force a literal collection name like "Calendar" here;
              # leave it null by default so we don't accidentally leak a
              # remote collection name into khal's default_calendar setting.
              primaryCollection = if acc.primaryCollection != null then acc.primaryCollection else null;
              khal = {
                enable = true;
                color = acc.calendarColor;
                type = "discover";
                glob = "*";
              };
              # Build the list of vdirsyncer collections. If a
              # `primaryCollection` is configured for the account include it
              # first, then append any additional `collections` the user set
              # in their Home Manager config.
              vdirsyncer =
                let
                  primaryList = if acc.primaryCollection != null then [ acc.primaryCollection ] else [ ];
                  extraList = if acc.collections != null then acc.collections else [ ];
                in
                {
                  enable = true;
                  collections = lib.concatLists [
                    primaryList
                    extraList
                  ];
                  conflictResolution = "remote wins";
                };
              remote = {
                type = "caldav";
                url = if acc.caldavUrl != null then acc.caldavUrl else defaultCaldavUrl acc.email;
                userName = if acc.calendarUser != null then acc.calendarUser else acc.email;
                passwordCommand = passwordCommand;
              };
              local = {
                type = "filesystem";
                fileExt = ".ics";
              };
            }
          )
        ) accountList
      );

      # Build contact sources for khard/vdirsyncer.
      contactAccounts = listToAttrs (
        concatMap (
          account:
          let
            name = account.name;
            acc = account.value;
            passwordCommand = [
              "cat"
              (getSecretPath acc)
            ];
          in
          optional acc.syncContacts (
            nameValuePair name {
              khard = {
                enable = true;
              };
              vdirsyncer = {
                enable = true;
                collections = [
                  "from a"
                  "from b"
                ];
                conflictResolution = "remote wins";
              };
              remote = {
                type = "carddav";
                url = if acc.carddavUrl != null then acc.carddavUrl else defaultCarddavUrl acc.email;
                userName = if acc.contactsUser != null then acc.contactsUser else acc.email;
                passwordCommand = passwordCommand;
              };
              local = {
                type = "filesystem";
                fileExt = ".vcf";
                # CardDAV servers often expose a single addressbook called
                # 'card' under the account path; vdirsyncer will create a
                # subdirectory for that collection. Point local storage at
                # that subdirectory so khard reads the .vcf files.
                path = "${config.home.homeDirectory}/.local/share/contacts/${name}/card";
              };
            }
          )
        ) accountList
      );

      calendarNames = attrNames calendarAccounts;
      primaryCalendarNames = lib.filter (n: n != null) (
        mapAttrsToList (name: value: if value.primary or false then name else null) calendarAccounts
      );
      defaultCalendarName =
        if hasCalendars then
          if primaryCalendarNames != [ ] then
            builtins.head primaryCalendarNames
          else
            builtins.head calendarNames
        else
          null;

      hasEmail = emailAccounts != { };
      hasCalendars = calendarAccounts != { };
      hasContacts = contactAccounts != { };
      needVdirsyncer = hasCalendars || hasContacts;
      # (no activation-time folder injection data required here)
    in
    mkMerge [
      # Always materialise SOPS secrets for enabled accounts and toggle vdirsyncer globally.
      {
        sops.secrets = sopsSecrets;
        programs.vdirsyncer.enable = needVdirsyncer;
      }

      # (no additional activation hooks; keep account generation as-is)

      # Email client (aerc) + account definitions.
      (mkIf hasEmail {
        home.packages = with pkgs; [
          frgd.html-to-markdown
          glow
        ];
        accounts.email.accounts = emailAccounts;

        programs.aerc = {
          enable = true;
          extraConfig = {
            filters = {
              "text/html" = "${pkgs.frgd.html-to-markdown}/bin/html2markdown | glow -";
              "text/plain" = "colorize";
            };
            general = {
              "unsafe-accounts-conf" = true;
              "default-save-path" = "~/Downloads";
              "log-file" = "~/.local/share/aerc/aerc.log";
              "use-terminal-pinentry" = true;
            };
            ui = {
              "folders-sort" = "INBOX,Archive,*";
              "index-format" = "%f %t %-20.20s %?C?(%C) ?%S";
              "timestamp-format" = "%Y-%m-%d %H:%M";
              "this-year-time-format" = "%m-%d %H:%M";
            };
            compose = {
              "editor" = "nvim";
            };
          };
        };
      })

      # Calendar sync / khal integration.
      (mkIf (cfg.calendar.enable && hasCalendars) {
        home.packages = with pkgs; [
          khal
          vdirsyncer
        ];

        accounts.calendar = {
          basePath = "${config.home.homeDirectory}/.local/share/calendars";
          accounts = calendarAccounts;
        };

        programs.khal =
          let
            # Prefer an explicit host-provided default calendar, but only if
            # it refers to a known calendar section name (one of
            # `calendarNames`). Otherwise fall back to the computed
            # `defaultCalendarName` (first primary account or first enabled
            # calendar). Use a let-binding so Nix doesn't try to treat any of
            # these as top-level options.
            hostProvided = lib.attrByPath [ "default" "default_calendar" ] null cfg.calendar.settings;
            hostDefaultCalendar =
              if hostProvided != null && elem hostProvided calendarNames then
                hostProvided
              else
                defaultCalendarName;

            defaultCalendar =
              let
                firstAcc = lib.head (lib.attrValues calendarAccounts);
                collections = firstAcc.vdirsyncer.collections;
              in
              if collections != [ ] then lib.head collections else null;
          in
          {
            enable = true;

            locale = {
              timeformat = "%H:%M";
              dateformat = "%Y-%m-%d";
              longdateformat = "%Y-%m-%d";
              datetimeformat = "%Y-%m-%d %H:%M";
              longdatetimeformat = "%Y-%m-%d %H:%M";
              firstweekday = 0;
            };

            # Merge host-provided settings first, then apply an explicit
            # override for the default calendar so it always refers to the
            # computed/host-provided calendar name rather than any stray
            # literal (e.g. "Calendar").
            settings = recursiveUpdate cfg.calendar.settings ({
              default = {
                print_new = "path";
                default_calendar = if defaultCalendar != null then defaultCalendar else hostDefaultCalendar;
              };

              view = {
                agenda_event_format = "{calendar-color}{cancelled}{start-end-time-style} {title}{repeat-symbol}{reset}";
              };
            });
          };

        systemd.user.services.vdirsyncer-calendar = {
          Unit.Description = "Synchronize calendars";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
          };
        };

        systemd.user.timers.vdirsyncer-calendar = {
          Unit.Description = "Synchronize calendars every 15 minutes";
          Timer = {
            OnCalendar = "*:0/15";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      })

      # Contact sync / khard integration.
      (mkIf (cfg.contacts.enable && hasContacts) {
        home.packages = with pkgs; [
          khard
          vdirsyncer
        ];

        accounts.contact = {
          basePath = "${config.home.homeDirectory}/.local/share/contacts";
          accounts = contactAccounts;
        };

        programs.khard = {
          enable = true;
          settings = {
            general = {
              debug = false;
              default_action = "list";
              editor = "nvim";
              merge_editor = "vimdiff";
            };
            contact_table = {
              display = "first_name";
              group_by_addressbook = false;
              reverse = false;
              show_nicknames = true;
              show_uids = true;
              sort = "first_name";
            };
            vcard = {
              private_objects = [
                "ANNIVERSARY"
                "BDAY"
              ];
              preferred_vcard_version = "3.0";
              search_in_source_files = true;
              skip_unparsable = false;
            };
          };
        };

        systemd.user.services.vdirsyncer-contacts = {
          Unit.Description = "Synchronize contacts";
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
          };
        };

        systemd.user.timers.vdirsyncer-contacts = {
          Unit.Description = "Synchronize contacts every 30 minutes";
          Timer = {
            OnCalendar = "*:0/30";
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      })
    ]
  );
}
