{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.khal;
in
{
  options.frgd.cli-apps.khal = with types; {
    enable = mkBoolOpt false "khal calendar application";
    
    googleCalendar = {
      enable = mkBoolOpt false "Enable Google Calendar sync";
      username = mkOpt str "" "Google Calendar username/email";
      passwordCommand = mkOpt str "" "Command to get Google Calendar password";
    };

    icloudCalendar = {
      enable = mkBoolOpt false "Enable iCloud Calendar sync";  
      username = mkOpt str "" "iCloud username/email";
      passwordCommand = mkOpt str "" "Command to get iCloud password";
    };

    settings = mkOpt attrs {} "Additional khal configuration settings";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      khal
      vdirsyncer
    ];

    # Configure calendar accounts for vdirsyncer
    accounts.calendar = {
      basePath = "$HOME/.local/share/calendars";
      
      accounts = mkMerge [
        # Google Calendar configuration
        (mkIf cfg.googleCalendar.enable {
          google = {
            primary = true;
            primaryCollection = "Calendar";
            khal = {
              enable = true;
              color = "light blue";
            };
            vdirsyncer = {
              enable = true;
              collections = ["from a" "from b"];
              conflictResolution = "remote wins";
            };
            remote = {
              type = "caldav";
              url = "https://apidata.googleusercontent.com/caldav/v2/${cfg.googleCalendar.username}/events";
              userName = cfg.googleCalendar.username;
              passwordCommand = cfg.googleCalendar.passwordCommand;
            };
            local = {
              type = "filesystem";
              fileExt = ".ics";
            };
          };
        })

        # iCloud Calendar configuration  
        (mkIf cfg.icloudCalendar.enable {
          icloud = {
            khal = {
              enable = true;
              color = "light green";
            };
            vdirsyncer = {
              enable = true;
              collections = ["from a" "from b"];
              conflictResolution = "remote wins";
            };
            remote = {
              type = "caldav";
              url = "https://caldav.icloud.com";
              userName = cfg.icloudCalendar.username;
              passwordCommand = cfg.icloudCalendar.passwordCommand;
            };
            local = {
              type = "filesystem";
              fileExt = ".ics";
            };
          };
        })
      ];
    };

    # Enable vdirsyncer for calendar sync
    programs.vdirsyncer.enable = true;

    # Configure khal
    programs.khal = {
      enable = true;
      
      locale = {
        timeformat = "%H:%M";
        dateformat = "%Y-%m-%d";
        longdateformat = "%Y-%m-%d";
        datetimeformat = "%Y-%m-%d %H:%M";
        longdatetimeformat = "%Y-%m-%d %H:%M";
        firstweekday = 0; # Monday
      };

      settings = recursiveUpdate {
        default = {
          print_new = "path";
          default_calendar = mkIf cfg.googleCalendar.enable "google";
        };
        
        view = {
          agenda_event_format = "{calendar-color}{cancelled}{start-end-time-style} {title}{repeat-symbol}{reset}";
        };
      } cfg.settings;
    };

    # Systemd service to sync calendars automatically
    systemd.user.services.vdirsyncer = mkIf (cfg.googleCalendar.enable || cfg.icloudCalendar.enable) {
      Unit = {
        Description = "Synchronize calendars";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
      };
    };

    systemd.user.timers.vdirsyncer = mkIf (cfg.googleCalendar.enable || cfg.icloudCalendar.enable) {
      Unit = {
        Description = "Synchronize calendars every 15 minutes";
      };
      Timer = {
        OnCalendar = "*:0/15"; # Every 15 minutes
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}