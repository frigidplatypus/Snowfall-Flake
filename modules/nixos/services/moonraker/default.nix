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
  cfg = config.frgd.services.moonraker;
in
{
  options.frgd.services.moonraker = with types; {
    enable = mkBoolOpt false "moonraker";
  };

  config = mkIf cfg.enable {
    sops.secrets.moonraker_secrets = {
      owner = "root";
      group = config.services.moonraker.group;
      path = "/var/lib/moonraker/config/moonraker.secrets";
    };
    services.moonraker = {
      user = "root";
      enable = true;
      # bind on all interfaces so Fluidd (or other remote UIs) can connect
      address = "0.0.0.0";
      allowSystemControl = true;
      settings = {
        # octoprint_compat = { };
        history = { };
        zeroconf = { };
        analysis = { };
        secrets = { };
        # "power homeassistant_switch" = {
        #   type = "homeassistant";
        #   address = "ha.frgd.us";
        #   port = 8443;
        #   device = "switch.ender_3";
        #   # The token option may be a template
        #   token = "{secrets.home_assistant.token}";
        #   domain = "switch";
        # };
        authorization = {
          force_logins = false;
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
            "192.168.0.0/16"
            "100.64.0.0/10"
            "FE80::/10"
            "::1/128"
          ];
        };
        # "notifier hassio" = {
        #   url = "{secrets.moonraker_secrets.home_assistant_notify_url.url}";
        #   events = "*";
        # };
      };
    };
  };
}
