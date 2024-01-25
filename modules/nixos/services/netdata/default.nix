{ config, pkgs, lib, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.netdata;
in {
  options.frgd.services.netdata = with types; {
    enable = mkBoolOpt false "Whether or not to configure netdata support.";
    gui = mkBoolOpt false
      "Whether or not to enable a gui to configure netdata support.";
  };

  config = mkIf cfg.enable {
    frgd.security.sops = enabled;
    sops.secrets.netdata_claim_token = {
      owner = "netdata";
      group = "netdata";
    };
    services.netdata = {
      enable = true;
      claimTokenFile = config.sops.secrets.netdata_claim_token.path;
      package = pkgs.netdata.override { withCloud = true; };
    };
  };
}
