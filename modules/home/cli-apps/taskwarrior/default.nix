{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
  let
    cfg = config.frgd.cli-apps.taskwarrior;
  in
  {
    options.frgd.cli-apps.taskwarrior = with types; {
      enable = mkBoolOpt false "Whether or not to enable Taskwarrior.";
      recurrence = {
        enable = mkBoolOpt false "Whether or not to enable recurrence (only enable on one device).";
      };
      taskpirate = {
        enable = mkBoolOpt false "Whether or not to enable taskpirate hooks.";
        hooksDir = mkOpt str "~/.local/share/task/hooks" "Location (in home) where task hooks will be written";
      };
  };

  config = mkIf cfg.enable (let
      # common python environment used by taskwarrior helpers
      pythonWithTasklib = pkgs.python3.withPackages (python-pkgs: [ python-pkgs.tasklib ]);

      # common packages for all platforms
      commonPkgs = [
        pkgs.taskwarrior-tui
        pkgs.tasksh
        pkgs.vit
        pythonWithTasklib
      ];

      # platform-specific additions
      basePkgs = if pkgs.stdenv.isLinux then commonPkgs ++ [ pkgs.taskopen ] else commonPkgs;

      # Normalize a leading '~/'
      hooksDir = replaceStrings ["~/"] [""] cfg.taskpirate.hooksDir;
    in {
      programs.taskwarrior = {
        enable = true;
        package = pkgs.taskwarrior3;
        colorTheme = "dark-violets-256";
        # dataLocation = mkIf (cfg.dataLocation) cfg.dataLocation;
        config = {
          confirmation = false;
          hooks.location = mkIf cfg.taskpirate.enable cfg.taskpirate.hooksDir;
          recurrence = mkIf cfg.recurrence.enable "on";
          report.minimal.filter = "status:pending";
          report.active.columns = [
            "id"
            "start"
            # "entry.age"
            "priority"
            "project"
            "due"
            "description"
          ];
          report.active.labels = [
            "ID"
            "Started"
            "Age"
            "Priority"
            "Project"
            "Due"
            "Description"
          ];
          urgency.uda.priority.L.coefficient = -1.8;
          uda.notification_repeat_enable.type = "string";
          uda.notification_repeat_enable.values = "true,false";
          uda.notification_repeat_enable.label = "Repeat Notification";

          uda.notification_repeat_delay.type = "duration";
          uda.notification_repeat_delay.label = "Repeat Delay";

          uda = {
            notification_date = {
              type = "date";
              label = "Notification Date";
            };
          };
          context.western.read = "project:Western or project:Inbox or priority:H";
          context.western.write = "project:Western";
          context.home.read = "project.not:Western";
          context.home.write = "project:Personal";
          context."coram deo".read = "project:'Coram Deo' and due.before:tomorrow";
          context."coram deo".write = "project:Inbox";
          sync.server.url = "https://tasks.fluffy-rooster.ts.net";
          sync.server.client_id = "d790343c-de82-419b-a5ad-0f2aa9c5130b";
          sync.encryption_secret = "7c0b8b0c-6de0-4b15-b4c3-9bafae2ba872";
        };
      };

      home.packages = basePkgs ++ (if cfg.taskpirate.enable then [ pkgs.frgd.taskpirate ] else []);

      home.file = mkIf cfg.taskpirate.enable {
        # ensure hooks dir exists (create a .keep file so home-manager creates the directory)
        "${hooksDir}/.keep".text = "";

        # official hooks provided by the package
        "${hooksDir}/on-add-pirate" = {
          source = "${pkgs.frgd.taskpirate}/bin/on-add-pirate";
        };
        "${hooksDir}/on-modify-pirate" = {
          source = "${pkgs.frgd.taskpirate}/bin/on-modify-pirate";
        };
      };      frgd.services.taskwarrior-sync = enabled;
    });
}
