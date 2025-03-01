{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.cli-apps.taskwarrior;
in
{
  options.frgd.cli-apps.taskwarrior = {
    enable = mkEnableOption "Taskwarrior";
    recurrence = {
      enable = mkEnableOption "Recurrence, only enable on one device.";
    };
    # dataLocation = mkOption {
    #   type = types.string;
    #   description = ''
    #     The location of the Taskwarrior data.
    #   '';
    # };
  };

  config = mkIf cfg.enable {

    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
      colorTheme = "dark-violets-256";
      # dataLocation = mkIf (cfg.dataLocation) cfg.dataLocation;
      config = {
        confirmation = false;
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
        sync.server.url = "https://tasks.fluffy-rooster.ts.net";
        sync.server.client_id = "d790343c-de82-419b-a5ad-0f2aa9c5130b";
        sync.encryption_secret = "7c0b8b0c-6de0-4b15-b4c3-9bafae2ba872";
      };
    };

    home.packages =
      if pkgs.stdenv.isLinux then
        [
          pkgs.taskopen
          pkgs.taskwarrior-tui
          pkgs.tasksh
          pkgs.vit
          (pkgs.python3.withPackages (python-pkgs: [ python-pkgs.tasklib ]))
        ]
      else
        [
          pkgs.taskwarrior-tui
          pkgs.tasksh
          pkgs.vit
          (pkgs.python3.withPackages (python-pkgs: [ python-pkgs.tasklib ]))
        ];
    frgd.services.taskwarrior-sync = enabled;
  };
}
