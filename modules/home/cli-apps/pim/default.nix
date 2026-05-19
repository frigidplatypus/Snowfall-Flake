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
      email = "jus10mar10@gmail.com";
      calendarColor = "yellow";
      syncMail = false;
      caldavUrl = "https://caldav.icloud.com/";
      carddavUrl = "https://contacts.icloud.com/";
      appPasswordSecret = "apple_app_password";
    };
  };

  cfg = config.frgd.cli-apps.pim;

  getSecretPath = acc: config.sops.secrets.${acc.appPasswordSecret}.path;

  defaultCaldavUrl = email: "https://apidata.googleusercontent.com/caldav/v2/${email}/events";
  defaultCarddavUrl =
    email: "https://www.googleapis.com/carddav/v1/principals/${email}/lists/default/";
in
{
  options.frgd.cli-apps.pim = with types; {
    enable = mkBoolOpt false "Personal Information Management suite (email, calendar, contacts)";

    accounts =
      mkOpt
        (attrsOf (
          types.submodule (
            { name, ... }:
            let
              defs = accountDefaults.${name} or { };
            in
            {
              options = {
                enable = mkBoolOpt true "Enable this account.";
                email = mkOpt str (defs.email or "") "Email address for the account.";
                realName = mkOpt str "Justin Martin" "Display name used by mail clients.";
                primary = mkBoolOpt false "Set as the primary account.";
                primaryCollection =
                  mkOpt (nullOr str) null
                    "Name of the primary collection on the remote (defaults to server default).";
                appPasswordSecret = mkOpt str (defs.appPasswordSecret or "${name}_app_password"
                ) "Name of the SOPS secret containing the app password.";
                imapFlavor = mkOpt str "gmail.com" "home-manager IMAP/SMTP flavor (e.g., gmail.com).";
                syncMail = mkBoolOpt (defs.syncMail or true) "Synchronize email for this account.";
                syncCalendar = mkBoolOpt true "Synchronize calendars for this account.";
                calendarColor = mkOpt str (defs.calendarColor or "light blue"
                ) "Calendar color as rendered in khal.";
                caldavUrl = mkOpt (nullOr str) (defs.caldavUrl or null
                ) "Override the CalDAV URL; defaults to Google if unset.";
                calendarUser = mkOpt (nullOr str) (defs.calendarUser or null
                ) "Override the CalDAV username; defaults to the account email.";
                syncContacts = mkBoolOpt true "Synchronize contacts for this account.";
                carddavUrl = mkOpt (nullOr str) (defs.carddavUrl or null
                ) "Override the CardDAV URL; defaults to Google if unset.";
                contactsUser = mkOpt (nullOr str) (defs.contactsUser or null
                ) "Override the CardDAV username; defaults to the account email.";
                folders =
                  mkOpt (nullOr str) null
                    "Comma-separated list of folders to show in aerc for this account.";
                collections = mkOpt (nullOr (
                  listOf str
                )) null "List of additional CalDAV collection ids or names to sync.";
              };
            }
          )
        ))
        {
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
            email = "jus10mar10@gmail.com";
            calendarColor = "yellow";
            syncMail = false;
            caldavUrl = "https://caldav.icloud.com/";
            carddavUrl = "https://contacts.icloud.com/";
            appPasswordSecret = "apple_app_password";
          };
        }
        "Account definitions keyed by name.";

    calendar = {
      enable = mkBoolOpt false "Enable calendar client (khal)";
      settings = mkOpt attrs { } "Additional khal configuration settings";
    };

    contacts = {
      enable = mkBoolOpt true "Enable contact management (khard)";
    };
  };

  config = mkIf cfg.enable (
    let
      enabledAccounts = filterAttrs (_: acc: acc.enable) cfg.accounts;
      accountList = attrsToList enabledAccounts;

      sopsSecrets = listToAttrs (
        map (account: nameValuePair account.value.appPasswordSecret { }) accountList
      );

      emailAccounts = mapAttrs (_: acc: {
        realName = acc.realName;
        address = acc.email;
        flavor = acc.imapFlavor;
        aerc = {
          enable = true;
          extraAccounts.default = "INBOX";
        };
        primary = acc.primary;
        passwordCommand = "cat ${getSecretPath acc}";
      }) (filterAttrs (_: acc: acc.syncMail) enabledAccounts);

      buildCalendar =
        account:
        let
          name = account.name;
          acc = account.value;
          passwordCommand = [
            "cat"
            (getSecretPath acc)
          ];
        in
        nameValuePair name {
          primary = acc.primary;
          primaryCollection = acc.primaryCollection;
          khal = {
            enable = true;
            color = acc.calendarColor;
            type = "discover";
            glob = "*";
          };
          vdirsyncer = {
            enable = true;
            collections =
              optionals (acc.primaryCollection != null) [ acc.primaryCollection ]
              ++ optionals (acc.collections != null) acc.collections;
            conflictResolution = "remote wins";
          };
          remote = {
            type = "caldav";
            url = if acc.caldavUrl != null then acc.caldavUrl else defaultCaldavUrl acc.email;
            userName = if acc.calendarUser != null then acc.calendarUser else acc.email;
            inherit passwordCommand;
          };
          local = {
            type = "filesystem";
            fileExt = ".ics";
          };
        };

      buildContact =
        account:
        let
          name = account.name;
          acc = account.value;
          passwordCommand = [
            "cat"
            (getSecretPath acc)
          ];
        in
        nameValuePair name {
          khard = {
            enable = true;
            type = "discover";
          };
          vdirsyncer = {
            enable = true;
            collections = null;
            conflictResolution = "remote wins";
          };
          remote = {
            type = "carddav";
            url = if acc.carddavUrl != null then acc.carddavUrl else defaultCarddavUrl acc.email;
            userName = if acc.contactsUser != null then acc.contactsUser else acc.email;
            inherit passwordCommand;
          };
          local = {
            type = "filesystem";
            fileExt = ".vcf";
            path = "${config.home.homeDirectory}/.local/share/contacts/${name}";
          };
        };

      calendarAccounts = listToAttrs (
        concatMap (a: optional a.value.syncCalendar (buildCalendar a)) accountList
      );

      contactAccounts = listToAttrs (
        concatMap (a: optional a.value.syncContacts (buildContact a)) accountList
      );

      hasEmail = emailAccounts != { };
      hasCalendars = calendarAccounts != { };
      hasContacts = contactAccounts != { };
      needVdirsyncer = hasCalendars || hasContacts;
    in
    mkMerge [
      {
        sops.secrets = sopsSecrets;
        programs.vdirsyncer.enable = needVdirsyncer;
      }

      (mkIf hasEmail {
        home.packages = with pkgs; [
          frgd.html-to-markdown
          glow
          matcha
        ];
        accounts.email.accounts = emailAccounts;

        programs.aerc = {
          enable = true;
          extraConfig = {
            filters = {
              "text/html" = "!${pkgs.frgd.html-to-markdown}/bin/html2markdown | ${pkgs.glow}/bin/glow -p";
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

      (mkIf (cfg.calendar.enable && hasCalendars) {
        home.packages = with pkgs; [
          khal
          vdirsyncer
        ];

        accounts.calendar = {
          basePath = "${config.home.homeDirectory}/.local/share/calendars";
          accounts = calendarAccounts;
        };

        programs.khal = {
          enable = true;
          locale = {
            timeformat = "%H:%M";
            dateformat = "%Y-%m-%d";
            longdateformat = "%Y-%m-%d";
            datetimeformat = "%Y-%m-%d %H:%M";
            longdatetimeformat = "%Y-%m-%d %H:%M";
            firstweekday = 0;
          };
          settings = recursiveUpdate cfg.calendar.settings {
            default = {
              print_new = "path";
            };
            view = {
              agenda_event_format = "{calendar-color}{cancelled}{start-end-time-style} {title}{repeat-symbol}{reset}";
            };
          };
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
