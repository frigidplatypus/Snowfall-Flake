{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.frgd) enabled;

  cfg = config.frgd.cli-apps.atuin;
in
{
  options.frgd.cli-apps.atuin = {
    enable = mkEnableOption "atuin";
  };

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        enter_accept = true;
        # search_mode = "prefix";
      };
    };
  };
}
