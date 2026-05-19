# PIM Module — `frgd.cli-apps.pim`

Personal Information Management suite for the terminal: **email**, **calendar**, and **contacts**. Built on:

- **aerc** — terminal email client (IMAP/SMTP)
- **khal** — terminal calendar client
- **khard** — terminal contact manager
- **vdirsyncer** — CalDAV/CardDAV sync engine
- **SOPS** — secret management for app passwords

## Quick start

```nix
frgd.cli-apps.pim = {
  enable = true;
  calendar.enable = true;
  contacts.enable = true;
};
```

## Options

### Top-level

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | `bool` | `false` | Enable the PIM suite |
| `accounts` | `attrsOf (submodule)` | (see below) | Account definitions keyed by name |
| `calendar.enable` | `bool` | `false` | Enable khal calendar client |
| `calendar.settings` | `attrs` | `{}` | Additional khal configuration settings |
| `contacts.enable` | `bool` | `true` | Enable khard contact management |

### Per-account options (`accounts.<name>.*`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | `bool` | `true` | Enable this account |
| `email` | `str` | *(varies)* | Email address |
| `realName` | `str` | `"Justin Martin"` | Display name for mail clients |
| `primary` | `bool` | `false` | Set as the primary account |
| `primaryCollection` | `nullOr str` | `null` | Primary calendar collection name/UUID on the remote |
| `appPasswordSecret` | `str` | *(varies)* | Name of the SOPS secret holding the app password |
| `imapFlavor` | `str` | `"gmail.com"` | IMAP/SMTP flavor (passed to home-manager's email module) |
| `syncMail` | `bool` | *(varies)* | Sync email for this account in aerc |
| `syncCalendar` | `bool` | `true` | Sync calendars via vdirsyncer |
| `calendarColor` | `str` | *(varies)* | Calendar color shown in khal |
| `caldavUrl` | `nullOr str` | *(varies)* | Custom CalDAV URL; defaults to Google |
| `calendarUser` | `nullOr str` | `null` | CalDAV username; defaults to account email |
| `syncContacts` | `bool` | `true` | Sync contacts via vdirsyncer |
| `carddavUrl` | `nullOr str` | *(varies)* | Custom CardDAV URL; defaults to Google |
| `contactsUser` | `nullOr str` | `null` | CardDAV username; defaults to account email |
| `folders` | `nullOr str` | `null` | Comma-separated folders to show in aerc |
| `collections` | `nullOr (listOf str)` | `null` | Additional CalDAV collection IDs or names to sync |

### Built-in account defaults

The module ships with defaults for three known accounts:

| Key | Email | Calendar color | Default `syncMail` |
|-----|-------|---------------|-------------------|
| `gmail` | `jus10mar10@gmail.com` | `"light blue"` | `true` |
| `jk` | `justin@justinandkathryn.com` | `"light green"` | `true` |
| `icloud` | `jus10mar10@gmail.com` | `"yellow"` | `false` |

The `icloud` account also defaults `caldavUrl`, `carddavUrl`, and `appPasswordSecret` so you only need `enable = true`.

## Full example

```nix
frgd.cli-apps.pim = {
  enable = true;

  accounts = {
    gmail = {
      enable = true;
      email = "jus10mar10@gmail.com";
      primary = true;
      folders = "INBOX,Sent,Archive";
      syncMail = true;
      syncCalendar = false;
      syncContacts = false;
    };

    jk = {
      enable = true;
      email = "justin@justinandkathryn.com";
      folders = "INBOX,Sent,Archive";
      syncMail = true;
      syncCalendar = false;
      syncContacts = false;
    };

    icloud = {
      enable = true;
      syncMail = false;
      syncCalendar = true;
      syncContacts = true;
      appPasswordSecret = "apple_app_password";
      primaryCollection = "5B01F554-FE12-4970-95F6-2F696FE78DE4";
      collections = [
        "93ecfb14-a475-4195-bec8-594e43e16837"
        "2896ed90-ccfb-4fff-8230-640843f10b70"
        "home"
      ];
    };
  };

  calendar = {
    enable = true;
    settings = {
      default = {
        default_calendar = "icloud";
      };
    };
  };

  contacts.enable = true;
};
```

## Secrets

Each account with `syncMail = true` or calendar/contact sync enabled needs an app password stored in a SOPS secret. The secret name is controlled by the `appPasswordSecret` option (defaults to `"<account-name>_app_password"` for unknown accounts, `"apple_app_password"` for iCloud).

The module automatically declares `sops.secrets.<name> = {}` for each enabled account, so the secret file just needs to exist in your SOPS configuration.

## Notes

### First-time contacts setup

After deploying, run this one-time step to discover and create the local contact collection:

```bash
yes | vdirsyncer discover contacts_<account-name>
```

For example with the `icloud` account:

```bash
yes | vdirsyncer discover contacts_icloud
```

This creates the local subdirectory needed by vdirsyncer (e.g., `~/.local/share/contacts/icloud/card/`). Subsequent `vdirsyncer sync` (via the systemd timer) will automatically sync contacts.

> **Why?** Vdirsyncer uses `collections = null` (auto-discovery) for contacts, which requires the local collection directory to exist first. The `yes | discover` step creates it from the remote's discovery response. Calendar collections are discovered automatically during sync because they use explicit collection IDs.

## Generated outputs

When enabled, the module configures:

- **`accounts.email.accounts`** — aerc IMAP/SMTP accounts (only for accounts with `syncMail = true`)
- **`accounts.calendar`** — vdirsyncer/khal calendar sync pairs (only for accounts with `syncCalendar = true`)
- **`accounts.contact`** — vdirsyncer/khard contact sync pairs (only for accounts with `syncContacts = true`)
- **`matcha`** — terminal email client (`pkgs.frgd.matcha`)
- **`programs.aerc`** — terminal email client with HTML-to-markdown rendering
- **`programs.khal`** — terminal calendar with auto-discovered collections
- **`programs.khard`** — terminal contact manager
- **`programs.vdirsyncer`** — CalDAV/CardDAV sync daemon
- **`systemd.user.timers.vdirsyncer-calendar`** — syncs calendars every 15 min
- **`systemd.user.timers.vdirsyncer-contacts`** — syncs contacts every 30 min
