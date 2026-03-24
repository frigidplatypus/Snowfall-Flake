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
      enableDefaultConfig = false;
      includes = [ "~/.ssh/config.d/*.conf" ];
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";
        };

        soft = {
          port = 23231;
          hostname = "git.frgd.us";
        };
      };
    };
  };
}
