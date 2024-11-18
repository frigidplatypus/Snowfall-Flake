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
    systemd.user.services.taskwarrior-webui-backend = {
      Unit = {
        Description = "Start taskwarrior-webui backend";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        ExecStart = "${pkgs.nodejs}/bin/npm start --prefix ${pkgs.frgd.taskwarrior-webui}/backend";
      };
    };

  };
}
