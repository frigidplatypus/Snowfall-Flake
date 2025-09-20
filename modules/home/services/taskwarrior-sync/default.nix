{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;

let

  cfg = config.frgd.services.taskwarrior-sync;
in
{
  options.frgd.services.taskwarrior-sync = with types; {
    enable = mkBoolOpt false "Whether or not to enable Taskwarrior sync service.";
    frequency = mkOpt str "*:0/5" "How often to run `taskwarrior sync`.";
    pkg = mkOpt package pkgs.taskwarrior3 "The version of Taskwarrior to use ";
  };

  config = mkIf cfg.enable {

    systemd.user.services.taskwarrior-sync = {
      Unit = {
        Description = "Taskwarrior sync";
      };
      Service = {
        CPUSchedulingPolicy = "idle";
        IOSchedulingClass = "idle";
        ExecStart = "${cfg.pkg}/bin/task synchronize";
      };
    };

    systemd.user.timers.taskwarrior-sync = {
      Unit = {
        Description = "Taskwarrior periodic sync";
      };
      Timer = {
        Unit = "taskwarrior-sync.service";
        OnCalendar = cfg.frequency;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
