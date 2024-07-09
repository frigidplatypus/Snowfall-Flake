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
  cfg = config.frgd.system.home-wifi;
in
{
  options.frgd.system.home-wifi = with types; {
    enable = mkBoolOpt false "Whether or not to manage home-wifi settings.";
  };

  config = mkIf cfg.enable {

    sops.secrets.wireless_env = { };
    networking.wireless.environmentFile = config.sops.secrets.wireless_env.path;
    networking.wireless.networks = {
      Mar10.psk = "@PSK_MAR10@";
    };
  };
}
