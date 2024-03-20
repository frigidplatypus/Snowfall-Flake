{ lib, config, ... }:
with lib;
with lib.frgd;
let cfg = config.frgd.tools.ssh;
in {
  options.frgd.tools.ssh = { enable = mkEnableOption "SSH"; };

  config = mkIf cfg.enable {
    services.ssh-agent = enabled;
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      matchBlocks = {
        soft = {
          port = 23231;
          hostname = "git.frgd.us";
        };
      };
      #extraConfig = ''
      #  Host *
      #    HostKeyAlgorithms +ssh-rsa
      #'';
    };
  };
}
