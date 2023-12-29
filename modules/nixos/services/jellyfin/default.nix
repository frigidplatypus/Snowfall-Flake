{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.jellyfin;
in {
  options.frgd.services.jellyfin = with types; {
    enable = mkBoolOpt false "Whether or not to enable jellyfin.";
  };

  config = mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}

