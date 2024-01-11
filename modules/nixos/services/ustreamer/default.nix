{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.ustreamer;
in {
  options.frgd.services.ustreamer = with types; {
    enable = mkBoolOpt false "Whether or not to enable ustreamer.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ ustreamer ];
    systemd.services.ustreamer = {
      wantedBy = [ "multi-user.target" ];
      description = "uStreamer for video0";
      serviceConfig = {
        Type = "simple";
        ExecStart =
          "${pkgs.ustreamer}/bin/ustreamer --encoder=HW --persistent --drop-same-frames=30";
      };
    };
  };
}

