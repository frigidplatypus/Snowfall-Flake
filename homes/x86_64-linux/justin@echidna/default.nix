{
  lib,
  config,
  pkgs,
  osConfig ? { },
  format ? "unknown",
  ...
}:
with lib;
with lib.frgd;
{
  sops.secrets.vikunja_api_key = { };
  sops.secrets.apple_app_password = { };
  frgd = {
    suites.common = enabled;
    user = {
      enable = true;
      name = "justin";
    };

    desktop = {
      hyprland = {
        enable = true;
        extra-config = {
          monitor = "eDP-1, 1920x1080, 0x0, 1";
        };
      };
    };
    apps = {
      obsidian = enabled;
      kitty = enabled;
      matrix_clients = enabled;
      ghostty = enabled;
    };
    security = {
      sops = {
        enable = true;
        miniflux_config = enabled;
      };
    };
    cli-apps = {
      pim = {
        enable = true;
        accounts = {
          gmail = {
            enable = true;
            email = "jus10mar10@gmail.com";
            primary = true;
            calendarColor = "light blue";
            # Only show these folders in aerc for a minimal list
            folders = "INBOX,Sent,Archive";
            syncMail = true;
            syncCalendar = false;
            syncContacts = false;
          };
          jk = {
            enable = true;
            email = "justin@justinandkathryn.com";
            calendarColor = "light green";
            folders = "INBOX,Sent,Archive";
            syncMail = true;
            syncCalendar = false;
            syncContacts = false;
          };
          icloud = {
            enable = true;
            primary = false;
            email = "jus10mar10@gmail.com";
            calendarColor = "yellow";
            syncMail = false;
            syncCalendar = true;
            syncContacts = true;
            appPasswordSecret = "apple_app_password";
            caldavUrl = "https://caldav.icloud.com/";
            carddavUrl = "https://contacts.icloud.com/";
            calendarUser = "jus10mar10@gmail.com";
            contactsUser = "jus10mar10@gmail.com";
            # Prefer the Martin Family Calendar as the primary collection
            # (discovered via `vdirsyncer discover`); also sync the other
            # Family collection UUID so both family calendars are available.
            primaryCollection = "5B01F554-FE12-4970-95F6-2F696FE78DE4";
            collections = [
              "93ecfb14-a475-4195-bec8-594e43e16837"
              "2896ed90-ccfb-4fff-8230-640843f10b70"
              "bca077e4f0da7a50c411c079c843d1d5826d2caf9667a2aed7d7ef9b3ca666bd"
              "home"
            ];
          };
        };
        contacts.enable = true;
        calendar = {
          enable = true;
          settings = {
            default = {
              default_calendar = "icloud";
            };
          };
        };
      };
      neovim = enabled;
      home-manager = enabled;
      local-scripts = enabled;
      atuin = disabled;
      ranger = enabled;
      fish = enabled;
      matrix_clients = enabled;
      hass-cli = enabled;
      cliflux = enabled;
      yazi = enabled;
      opencode = enabled;
    };
    services = {
      espanso = {
        enable = true;
        western_snippets = {
          enable = true;
        };
      };
    };
    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
      charms = enabled;
      ssh = enabled;
      nix-index = enabled;
    };
  };

  home.packages = with pkgs; [ cfonts ];

}
