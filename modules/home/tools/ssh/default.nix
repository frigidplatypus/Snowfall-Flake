{ lib, config, ... }:
with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.ssh;
in
{
  options.frgd.tools.ssh = with types; {
    enable = mkBoolOpt false "Whether or not to enable SSH.";
  };

  config = mkIf cfg.enable {
    services.ssh-agent = enabled;
    programs.ssh = {
      enable = true;
      # Disable default config to avoid deprecation warnings
      enableDefaultConfig = false;
      matchBlocks = {
        # Default configuration for all hosts
        "*" = {
          addKeysToAgent = "yes";
          # Other common default settings can be added here
        };
        
        # Specific host configurations
        soft = {
          port = 23231;
          hostname = "git.frgd.us";
        };
      };
      # IdentityAgent configuration moved to frgd.apps._1password module
    };
  };
}
