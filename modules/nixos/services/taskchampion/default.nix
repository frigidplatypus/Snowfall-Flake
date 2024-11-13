{
  lib,
  pkgs,
  config,
  options,
  ...
}:

let
  cfg = config.frgd.services.taskchampion;

  inherit (lib) types mkEnableOption mkIf;
in
{
  options.frgd.services.taskchampion = with types; {
    enable = mkEnableOption "taskchampion";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      taskwarrior3
    ];
    services.taskchampion-sync-server = {
      enable = true;
    };
    systemd.timers = {
      "task-sync" = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "300";
          OnUnitActiveSec = "300";
          Unit = "task-sync.service";
        };
      };
    };

    systemd.services = {
      "task-sync" = {
        script = ''
          set -eu
          ${pkgs.taskwarrior3}/bin/task sync && ${pkgs.curl}/bin/curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/ac74a7a0-9875-4ba4-a5d7-195f5e95c0a8
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts = {
        "tasks.fluffy-rooster.ts.net" = {
          extraConfig = ''
            reverse_proxy http://127.0.0.1:8084
            encode gzip
          '';
        };
      };
    };
  };
}
