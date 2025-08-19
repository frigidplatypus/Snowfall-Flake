{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.tsidp;
in
{
  options.frgd.services.tsidp = with types; {
    enable = mkBoolOpt false "tsidp";
    port = mkOption {
      type = types.port;
      default = 8443;
      description = "Port for tsidp to listen on.";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/tsidp";
      description = "tsidp state dir";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.tsidp = {
      enable = true;
      description = "Tailscale OpenID Connect service";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        TS_HOSTNAME = "idp";
        TS_USERSPACE = "false";
        TAILSCALE_USE_WIP_CODE = "1";
        TS_STATE_DIR = "${cfg.dataDir}";
      };

      serviceConfig = {
        Type = "simple";
        RestartSec = 5;
        Restart = "always";
        User = "root";
        ExecStart = "${pkgs.tailscale}/bin/tsidp -use-local-tailscaled -port ${toString cfg.port}";
      };
    };

  };
}
