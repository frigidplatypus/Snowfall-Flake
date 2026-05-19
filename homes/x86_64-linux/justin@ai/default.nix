{ lib, config, ... }:
with lib;
with lib.frgd;
{
  sops.secrets.apple_app_password = { };

  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common = enabled;

    security.sops = enabled;

    cli-apps = {
      ai-tools = enabled;
      pim = {
        enable = true;
        accounts = {
          gmail = {
            enable = true;
            email = "jus10mar10@gmail.com";
            primary = true;
            calendarColor = "light blue";
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
    };

    tools = {
      git = enabled;
      misc = enabled;
    };
  };
}
