{
  lib,
  config,
  options,
  ...
}:

let
  cfg = config.frgd.services.mealie;

  inherit (lib) types mkEnableOption mkIf;
in
{
  options.frgd.services.mealie = with types; {
    enable = mkEnableOption "mealie";
  };

  config = mkIf cfg.enable {
    services.mealie = {
      enable = true;
      listenAddress = "127.0.0.1";
      settings = {

        #OpenID Connect
        OIDC_AUTH_ENABLED = "true";
        OIDC_CONFIGURATION_URL = "https://dns.fluffy-rooster.ts.net/.well-known/openid-configuration";
        OIDC_AUTO_REDIRECT = "true";
        OIDC_CLIENT_ID = "unused";
        OIDC_CLIENT_SECRET = "unused";
        OIDC_PROVIDER_NAME = "Tailscale";
        OIDC_NAME_CLAIM = "email"; # needs to be set to username

      };
    };

  };
}
