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
  cfg = config.frgd.services.taskwarrior-api;
in
{
  options.frgd.services.taskwarrior-api = with types; {
    enable = mkBoolOpt false "Whether or not to enable taskwarrior-api.";
    port = mkOpt types.int 3000 "The port on which the taskwarrior-api will run.";
    host = mkOpt types.str "127.0.0.1" "The host on which the taskwarrior-api";

  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.frgd.taskwarrior-api
      pkgs.nodejs
    ];
    systemd.user.services.taskwarrior-api = {
      Unit = {
        Description = "Start taskwarrior-api";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Environment = [
          "NODE_ENV=production"
          "PORT=${toString cfg.port}"
          "HOST=${cfg.host}"
          "PATH=$PATH:${lib.makeBinPath [ pkgs.taskwarrior3 ]}"
        ];

        ExecStart = "${pkgs.nodejs}/bin/node ${pkgs.frgd.taskwarrior-api}/server/dist/app.js";
      };
    };

  };
}
