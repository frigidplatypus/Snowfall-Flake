{
  lib,
  modulesPath,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  services.caddy = {
    enable = true;
    virtualHosts = {
      "recipes.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:9000 {
            header_up X-Forwarded-Proto https
            header_down Strict-Transport-Security max-age=31536000
          }
          encode gzip
        '';
      };
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };

  # Mealie configuration moved from modules/nixos/services/mealie
  sops.secrets.mealie_env = {
    # owner = "mealie";
    # group = "mealie";
    mode = "0664";
  };

  services.mealie = {
    enable = true;
    listenAddress = "0.0.0.0";
    credentialsFile = config.sops.secrets.mealie_env.path;
    settings = {
      BASE_URL = "https://recipes.mar10s.cloud";
      ALLOW_PASSWORD_LOGIN = "true";
      OIDC_AUTH_ENABLED = "true";
      OIDC_SIGNUP_ENABLED = "true";
      OIDC_CONFIGURATION_URL = "${tsidpUrl}/.well-known/openid-configuration";
      OIDC_AUTO_REDIRECT = "false";
      OIDC_PROVIDER_NAME = "Tailscale";
      OIDC_REMEMBER_ME = "true";
      OIDC_USER_CLAIM = "email";
      OIDC_NAME_CLAIM = "name";
    };
  };
}
