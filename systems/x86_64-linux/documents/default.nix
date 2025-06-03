{
  lib,
  modulesPath,
  config,
  ...
}:
with lib;
with lib.frgd;
let
  oidcConfig = {
    # Base OIDC configuration for openid_connect provider
    baseConfig = {
      SCOPE = [
        "openid"
        "profile"
        "email"
      ];
      OAUTH_PKCE_ENABLED = true;
    };

    # Tailscale IDP provider configuration
    providers = {
      tsidp = {
        name = "Login with Tailscale";
        clientId = "tsidp"; # Referenced by environment variable TSIDP_CLIENT_ID
        clientSecret = "tsidp"; # Referenced by environment variable TSIDP_CLIENT_SECRET
        serverUrl = "https://dns.${tailnet}/.well-known/openid-configuration";
      };
      # Add more providers here as needed
    };
  };

  # Function to build the final OIDC providers structure according to Paperless-ngx docs
  buildOidcProvidersData = providers: {
    openid_connect = oidcConfig.baseConfig // {
      APPS = mapAttrsToList (providerId: providerConfig: {
        provider_id = providerId;
        name = providerConfig.name;
        client_id = providerConfig.clientId;
        secret = providerConfig.clientSecret;
        settings = {
          server_url = providerConfig.serverUrl;
        };
      }) providers;
    };
  };
in
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  services.caddy = {
    enable = true;
    logFormat = "level DEBUG";
    virtualHosts = {
      "documents.${tailnet}" = {
        extraConfig = ''

            reverse_proxy http://127.0.0.1:28981{
               # Standard reverse proxy headers go INSIDE the reverse_proxy block
               header_up Host {host}
               header_up X-Forwarded-Proto {scheme}
               header_up X-Real-IP {remote_host}
               header_up X-Forwarded-For {remote_host}
            }

          encode gzip
        '';
      };
    };
  };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets.justin_password.path;
    settings = {
      PAPERLESS_URL = "https://documents.${tailnet}";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1 ::1";
      PAPERLESS_LOGGING_LEVEL = "DEBUG";
      # Authentication settings for OIDC
      PAPERLESS_AUTHENTICATION_BACKENDS = "django.contrib.auth.backends.ModelBackend,allauth.account.auth_backends.AuthenticationBackend";

      # Required apps for social authentication - must be comma-separated strings, not a list
      # Note: We only need to add providers that aren't already included in Paperless-ngx's base configuration
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";

      # Site ID required by django-allauth
      PAPERLESS_SITE_ID = 1;

      # Build OIDC configuration with proper secret handling
      PAPERLESS_SOCIALACCOUNT_PROVIDERS = builtins.toJSON (buildOidcProvidersData oidcConfig.providers);

      # OIDC user signup settings according to Paperless-ngx docs
      PAPERLESS_SOCIALACCOUNT_AUTO_SIGNUP = "true";
      PAPERLESS_SOCIALACCOUNT_ALLOW_SIGNUPS = "true";

      # Optional: Set newly created users to be active by default
      PAPERLESS_AUTO_LOGIN_AFTER_SIGNUP = "true";

    };
  };

  services.borgbackup.jobs.home-danbst = {
    paths = "/var/lib/paperless";
    encryption.mode = "none";
    environment.BORG_RSH = "ssh -i /home/justin/.ssh/borg.pub";
    repo = "ssh://d9h4up4b@d9h4up4b.repo.borgbase.com/./repo";
    compression = "auto,zstd";
    startAt = "daily";
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    services = {
      borgmatic = {
        enable = true;

        # Directory to back up
        directories = [
          "/var/lib/paperless"
        ];

        # Where to store the backups - adjust to your backup location
        repositories = [
          "ssh://d9h4up4b@d9h4up4b.repo.borgbase.com/./repo"
          # Or remote: "ssh://user@backup-server/./paperless-backup.borg"
        ];

        # Optional: Set specific retention policy for these backups
        retention = {
          enable = true;
          keepDaily = 7; # Keep daily backups for the last week
          keepWeekly = 4; # Keep weekly backups for the last month
          keepMonthly = 6; # Keep monthly backups for the last 6 months
          keepYearly = 2; # Keep yearly backups for 2 years
        };

        # Optional: Configure backup schedule
        schedule = {
          enable = true;
          frequency = "daily";
          time = "02:30:00"; # Run at 2:30 AM
        };

        # Optional: Run a command before backup to ensure consistency
        hooks.beforeBackup = [
          "systemctl stop paperless"
        ];

        # Optional: Restart service after backup completes
        hooks.afterBackup = [
          "systemctl start paperless"
        ];

        # Optional: Send notification on failure
        hooks.onError = [
          "echo 'Paperless backup failed' | mail -s 'Backup Error' admin@example.com"
        ];
      };
      tailscale.tailscaleAuth = enabled;
      samba = {
        enable = true;
        shares = {
          paperless = {
            path = "${config.services.paperless.dataDir}/consume";
            browseable = true;
            public = false;
            extra-config = {
              # "create mask" = "0644";
              # "directory mask" = "0755";
              "force group" = config.services.paperless.user;
              "force user" = config.services.paperless.user;
              "write list" = "justin paperless paperless upload @${config.services.paperless.user}";
              "valid users" = "justin paperless paperless upload @${config.services.paperless.user}";
              "inherit permissions" = "yes";
            };
          };
        };
      };
    };
  };
}
