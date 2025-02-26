{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.unifiServer;
in
{
  options.frgd.services.unifiServer = with types; {
    enable = mkBoolOpt false "Whether or not to enable unifiServer.";
  };

  config = mkIf cfg.enable {
    services = {
      unifi = {
        enable = true;
        unifiPackage = pkgs.unifi;
        mongodbPackage = pkgs.mongodb-7_0;
        openFirewall = true;
      };
    };

  };
}
