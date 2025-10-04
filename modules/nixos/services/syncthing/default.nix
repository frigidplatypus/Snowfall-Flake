# TODO Fix user settings to pull from configuration instead of being hardcoded.

{
  options,
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.syncthing;
in
{
  options.frgd.services.syncthing = with types; {
    enable = mkBoolOpt false "Whether or not to enable Syncthing.";
  };

  config = mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
        user = "justin";
        dataDir = "/home/justin/syncthing"; # Default folder for new synced folders
        configDir = "/home/justin/.config/syncthing"; # Folder for Syncthing's settings and keys
        guiAddress = "0.0.0.0:8384";
      };
    };
  };
}
