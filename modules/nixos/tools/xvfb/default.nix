{
  options,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.xvfb;
in
{
  options.frgd.tools.xvfb = with types; {
    enable = mkBoolOpt false "Whether or not to install xvfb-run and tigervnc for headless browser auth.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ xvfb-run tigervnc ];

    systemd.services.xvfb = {
      description = "Virtual Framebuffer X Server";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.xvfb}/bin/Xvfb :99 -screen 0 1920x1080x24 +extension RANDR";
        Restart = "always";
        RestartSec = "2s";
      };
    };
  };
}
