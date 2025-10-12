# PIM (Personal Information Management) Setup Guide

This guide will help you set up the PIM suite which includes:
- **Email** (aerc) - Terminal-based email client
- **Calendar** (khal) - CLI calendar with Google Calendar and iCloud sync
- **Contacts** (khard) - Contact management with sync support

## Configuration Structure

The PIM module is located at `modules/home/cli-apps/pim/default.nix` and provides a unified interface for managing:

```nix
frgd.cli-apps.pim = {
  enable = true;
  
  email = {
    enable = true;
    accounts = {
      jk.enable = true;      # justin@justinandkathryn.com
      gmail.enable = true;   # jus10mar10@gmail.com
    };
  };
  
  calendar = {
    enable = true;
    googleCalendar.enable = true;
    icloudCalendar.enable = true;
  };
  
  contacts = {
    enable = true;  # Optional - for contact sync
    googleContacts.enable = true;
    icloudContacts.enable = true;
  };
};
```

## Email Setup (aerc)

Email is automatically configured with your existing accounts:
- `justin@justinandkathryn.com` (primary)
- `jus10mar10@gmail.com` (secondary)

Uses existing SOPS secrets:
- `sops.secrets.jk_app_password`
- `sops.secrets.gmail_app_password`

## Calendar Setup (khal + vdirsyncer)

### Prerequisites

1. **Google Calendar:**
   - Enable 2FA on your Google account
   - Generate an App Password for calendar access
   - Store securely: `echo "app-password" > ~/.config/google-calendar-password && chmod 600 ~/.config/google-calendar-password`

2. **iCloud Calendar:**
   - Enable 2FA on your Apple ID
   - Generate App-Specific Password for calendar access
   - Store securely: `echo "app-password" > ~/.config/icloud-calendar-password && chmod 600 ~/.config/icloud-calendar-password`

### Calendar Commands

```bash
# Initial setup
vdirsyncer discover
vdirsyncer sync

# Daily usage
khal calendar          # Show calendar view
khal agenda           # Show upcoming events
khal list today       # List today's events
ikhal                # Interactive calendar
khal new tomorrow 14:00 "Meeting"  # Create event
```

## Contact Setup (khard + vdirsyncer)

*Currently disabled by default - enable when ready*

### Prerequisites

1. **Google Contacts:**
   - Use same Google App Password as calendar
   - Store password: `echo "app-password" > ~/.config/google-contacts-password && chmod 600 ~/.config/google-contacts-password`

2. **iCloud Contacts:**
   - Use same iCloud App Password as calendar  
   - Store password: `echo "app-password" > ~/.config/icloud-contacts-password && chmod 600 ~/.config/icloud-contacts-password`

### Contact Commands

```bash
# List contacts
khard list

# Search contacts
khard list justin

# Add contact
khard new

# Edit contact
khard edit contact-name

# Show contact details
khard show contact-name
```

## Deployment

1. **Update credentials** in your home configuration
2. **Deploy the configuration:**
   ```bash
   home-manager switch --flake .#justin@t480
   ```
3. **Initial sync:**
   ```bash
   vdirsyncer discover
   vdirsyncer sync
   ```

## Automatic Syncing

The module automatically sets up systemd timers for:
- **Calendar sync:** Every 15 minutes
- **Contact sync:** Every 30 minutes (when enabled)

### Check sync status

```bash
# Check timers
systemctl --user list-timers vdirsyncer*

# Check service logs
journalctl --user -u vdirsyncer-calendar.service
journalctl --user -u vdirsyncer-contacts.service

# Manual sync
systemctl --user start vdirsyncer-calendar.service
systemctl --user start vdirsyncer-contacts.service
```

## Security with SOPS (Recommended)

For enhanced security, use SOPS for all passwords:

1. **Add to SOPS file:**
   ```yaml
   google_calendar_password: "your-app-password"
   icloud_calendar_password: "your-app-password"
   google_contacts_password: "your-app-password"
   icloud_contacts_password: "your-app-password"
   ```

2. **Update module configuration:**
   ```nix
   calendar = {
     googleCalendar = {
       passwordCommand = "cat ${config.sops.secrets.google_calendar_password.path}";
     };
     icloudCalendar = {
       passwordCommand = "cat ${config.sops.secrets.icloud_calendar_password.path}";
     };
   };
   ```

3. **Add SOPS secrets:**
   ```nix
   sops.secrets.google_calendar_password = { };
   sops.secrets.icloud_calendar_password = { };
   sops.secrets.google_contacts_password = { };
   sops.secrets.icloud_contacts_password = { };
   ```

## Integration Benefits

The unified PIM module provides:
- ✅ **Consistent configuration** - All PIM tools in one place
- ✅ **Shared credentials** - Reuse passwords across calendar/contacts
- ✅ **Coordinated syncing** - Separate timers for different data types
- ✅ **Modular enablement** - Enable only what you need
- ✅ **SOPS integration** - Secure credential management