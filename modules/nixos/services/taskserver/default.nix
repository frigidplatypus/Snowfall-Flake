{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.taskserver;
in {
  options.frgd.services.taskserver = with types; {
    enable = mkBoolOpt false "Whether or not to enable taskserver.";
  };

  config = mkIf cfg.enable {
    services.taskserver = {
      enable = true;
      openFirewall = true;
      fqdn = "tasks.frgd.us";
      organisations.frgd.users = [ "justin" ];
      listenHost = "100.109.184.126";
    };
  };
}

