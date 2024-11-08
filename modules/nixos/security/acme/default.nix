{
  lib,
  config,
  virtual,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption optional;
  inherit (lib.frgd) mkOpt;

  cfg = config.frgd.security.acme;
in
{
  options.frgd.security.acme = with lib.types; {
    enable = mkEnableOption "default ACME configuration";
    email = mkOpt str config.frgd.user.email "The email to use.";
    staging = mkOpt bool virtual "Whether to use the staging server or not.";
  };

  config = mkIf cfg.enable {
    sops.secrets.porkbun_api_key = { };
    security.acme = {
      acceptTerms = true;
      defaults = {
        dnsProvider = "porkbun";
        environmentFile = config.sops.secrests.porkbun_api_key.path;
        defaultEmail = cfg.email;

        group = mkIf config.services.nginx.enable "nginx";

      };
    };
  };
}
