# TODO Fix user settings to pull from configuration instead of being hardcoded.

{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.services.syncthing;
in {
  options.frgd.services.syncthing = { enable = mkEnableOption "Syncthing"; };

  config = mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
        user = "justin";
        dataDir =
          "/home/justin/syncthing"; # Default folder for new synced folders
        configDir =
          "/home/justin/.config/syncthing"; # Folder for Syncthing's settings and keys
        guiAddress = "0.0.0.0:8384";
      };
    };
  };
}
