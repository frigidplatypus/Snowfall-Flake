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
  cfg = config.frgd.services.taskwarrior-webui;
in
{
  options.frgd.services.taskwarrior-webui = with types; {
    enable = mkBoolOpt false "Whether or not to enable taskwarrior-webui.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      frgd.taskwarrior-webui
      nodejs
    ];

    systemd.services.taskwarrior-webui = {
      description = "Taskwarrior WebUI";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.nodejs}/bin/npm start --prefix ${pkgs.frgd.taskwarrior-webui}/backend";
        Restart = "always";
        RestartSec = "5";
        User = "justin";
      };
    };

    services.caddy = {
      enable = true;
      config = ''
        https://p5810.fluffy-rooster.ts.net {
          root * ${pkgs.frgd.taskwarrior-webui}/frontend/dist/
          reverse_proxy /api 127.0.0.1:3000
          file_server
        }
      '';
    };
  };
}
