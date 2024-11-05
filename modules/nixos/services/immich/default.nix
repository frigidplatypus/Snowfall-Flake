{
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.immich;
in
{
  options.frgd.services.immich = with types; {
    enable = mkBoolOpt false "Whether or not to enable immich.";
  };

  config = mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "nasnix.fluffy-rooster.ts.net";
      mediaLocation = "/storage/photos";
      openFirewall = true;
      machine-learning = {
        enable = false;
      };
      environment = {
        IMMICH_LOG_LEVEL = "verbose";
      };

    };
  };
}
