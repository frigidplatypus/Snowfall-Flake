{
  options,
  config,
  lib,
  pkgs,
  inputs,
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
        unifiPackage = pkgs.unifi8;
        openFirewall = true;
        #mongodbPackage = inputs.mongodb_pinned.legacyPackages.${system}.mongodb-5_0;
      };
    };
  };
}
