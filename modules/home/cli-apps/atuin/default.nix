{ lib, config, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.atuin;
in
{
  options.frgd.cli-apps.atuin = with types; {
    enable = mkBoolOpt false "Whether or not to enable atuin.";
  };

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      daemon = enabled;
      settings = {
        auto_sync = true;
        # sync_frequency = "5m";
        # enter_accept = true;
        # search_mode = "prefix";
      };
    };
  };
}
