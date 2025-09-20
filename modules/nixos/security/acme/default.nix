{
  lib,
  config,
  virtual,
  ...
}:
with lib;
with lib.frgd;
  let
    inherit (lib) mkIf optional;
    inherit (lib.frgd) mkOpt mkBoolOpt;

    cfg = config.frgd.security.acme;
  in
  {
    options.frgd.security.acme = with lib.types; {
      enable = mkBoolOpt false "Whether or not to enable default ACME configuration.";
    email = mkOpt str config.frgd.user.email "The email to use.";
    staging = mkOpt bool virtual "Whether to use the staging server or not.";
  };

  config = mkIf cfg.enable {
    frgd.security.sops = enabled;
    sops.secrets.porkbun_api_key = { };
    security.acme = {
      acceptTerms = true;
      defaults = {
        dnsProvider = "porkbun";
        environmentFile = config.sops.secrets.porkbun_api_key.path;
        dnsResolver = "1.1.1.1";
        email = cfg.email;

        group = mkIf config.services.nginx.enable "nginx";

      };
    };
  };
}
