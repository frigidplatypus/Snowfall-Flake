{
  lib,
  config,
  options,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.mealie;
in
{
  options.frgd.services.mealie = with types; {
    enable = mkBoolOpt false "Whether or not to enable mealie.";
  };

  config = mkIf cfg.enable {
    # Enable and configure Meilisearch with the latest package
    sops.secrets.mealie_env = {
      # owner = "mealie";
      # group = "mealie";
      mode = "0664";
    };

    services.mealie = {
      enable = true;
      listenAddress = "127.0.0.1";
      credentialsFile = config.sops.secrets.mealie_env.path;
      settings = {

        #OpenID Connect
        OIDC_AUTH_ENABLED = "true"; # Enable OIDC authentication
        OIDC_SIGNUP_ENABLED = "true"; # Allow new users to be created via OIDC
        OIDC_CONFIGURATION_URL = "${tsidpUrl}/.well-known/openid-configuration";
        OIDC_CLIENT_ID = "mealie"; # Should match your tsidp client configuration
        OIDC_CLIENT_SECRET = "mealie"; # Should match your tsidp client secret
        OIDC_AUTO_REDIRECT = "false"; # Set to true if you want to skip login page
        OIDC_PROVIDER_NAME = "Tailscale";
        OIDC_REMEMBER_ME = "true"; # Auto-extend sessions
        OIDC_SIGNING_ALGORITHM = "RS256"; # Default signing algorithm
        OIDC_USER_CLAIM = "email"; # Claim used to identify users
        OIDC_NAME_CLAIM = "name"; # Claim used for user's full name
        # Optional group-based access control
        # OIDC_USER_GROUP = "mealie-users";  # Users must be in this group
        # OIDC_ADMIN_GROUP = "mealie-admins";  # Users in this group become admins
        # OIDC_GROUPS_CLAIM = "groups";  # Claim containing user groups
      };
    };

  };
}
