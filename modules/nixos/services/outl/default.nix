{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.outl;
  outl = inputs.outl.packages.${pkgs.system}.outl;
in
{
  options.frgd.services.outl = with types; {
    enable = mkBoolOpt false "Whether to enable the outl sync server.";
    workspace = mkOpt str "/home/justin/outl" "Path to the outl workspace.";
    user = mkOpt str "justin" "User to run the outl sync server as.";
    group = mkOpt str "users" "Group to run the outl sync server as.";
    rustLog = mkOpt str "info" "RUST_LOG for the outl daemon.";
  };

  config = mkIf cfg.enable {
    systemd.services.outl-sync = {
      description = "outl background sync service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${outl}/bin/outl serve --workspace ${escapeShellArg cfg.workspace}";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = "RUST_LOG=${cfg.rustLog}";
      };
    };
  };
}
