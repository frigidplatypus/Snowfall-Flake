{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.moonraker;
in {
  options.frgd.services.moonraker = with types; {
    enable = mkBoolOpt false "moonraker";
  };

  config = mkIf cfg.enable {
    services.moonraker = {
      user = "root";
      enable = true;
      address = "0.0.0.0";
      allowSystemControl = true;
      settings = {
        octoprint_compat = { };
        history = { };
        authorization = {
          force_logins = true;
          cors_domains = [
            "*.local"
            "*.lan"
            "*://app.fluidd.xyz"
            "*://my.mainsail.xyz"
            "*://klipper.frgd.us"
            "*://klipper.fluffy-rooster.ts.net"
          ];
          trusted_clients = [
            "10.0.0.0/8"
            "127.0.0.0/8"
            "169.254.0.0/16"
            "172.16.0.0/12"
            "192.168.0.0/24"
            "100.85.139.61/32"
            "FE80::/10"
            "::1/128"
          ];
        };
      };
    };
  };
}
