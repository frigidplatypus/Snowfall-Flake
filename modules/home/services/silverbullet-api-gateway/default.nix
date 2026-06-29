{ config, lib, pkgs, inputs, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.silverbullet-api-gateway;
  inherit (inputs) silverbullet-api-gateway;
in
{
  imports = [ silverbullet-api-gateway.homeManagerModules.default ];

  options.frgd.services.silverbullet-api-gateway = with types; {
    enable = mkBoolOpt false "Whether to enable the SilverBullet API Gateway.";

    package = mkOption {
      type = package;
      default = silverbullet-api-gateway.packages.${pkgs.system}.default;
      defaultText = literalExpression
        "inputs.silverbullet-api-gateway.packages.\${pkgs.system}.default";
      description = "The silverbullet-api-gateway package to use.";
    };

    url = mkOption {
      type = str;
      default = "http://localhost:3000";
      description = "SilverBullet instance URL (SB_URL).";
    };

    page = mkOption {
      type = str;
      default = "inbox";
      description = "SilverBullet page to append data to (SB_PAGE).";
    };

    tokenFile = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        Path to a file containing the SB_AUTH_TOKEN. Use sops-nix to
        manage this file, or set token directly.
      '';
    };

    token = mkOption {
      type = nullOr str;
      default = null;
      description = "SilverBullet API token (SB_TOKEN).";
    };

    dataPattern = mkOption {
      type = nullOr str;
      default = "- [ ] [TEXT] ([DATE])";
      description = ''
        DATA_PATTERN template. Magic variables: [TEXT], [DATE], [SEPARATOR], [TAB].
        Set to null to append only the raw POST data.
      '';
    };

    separator = mkOption {
      type = str;
      default = "\n";
      description = "Separator string between appended entries (SEPARATOR).";
    };

    port = mkOption {
      type = port;
      default = 8080;
      description = "Port the gateway listens on.";
    };
  };

  # Import upstream module at top level (not under config — imports is a
  # module-system special, not a regular option)
  imports = [ silverbullet-api-gateway.homeManagerModules.default ];

  config = mkIf cfg.enable {
    # Configure the upstream service
    services.silverbullet-api-gateway = {
      enable = true;
      package = cfg.package;

      environment = {
        SB_URL = cfg.url;
        SB_PAGE = cfg.page;
        SEPARATOR = cfg.separator;
      } // optionalAttrs (cfg.dataPattern != null) { DATA_PATTERN = cfg.dataPattern; }
        // optionalAttrs (cfg.token != null) { SB_TOKEN = cfg.token; };
    };

    # Load token from file if tokenFile is set (via systemd LoadCredential)
    systemd.user.services.silverbullet-api-gateway = mkIf (cfg.tokenFile != null) {
      Service = {
        LoadCredential = "sb-token:${cfg.tokenFile}";
        Environment = "SB_TOKEN=%d/sb-token";
        # systemd reads the credential file and exposes it via $CREDENTIALS_DIRECTORY
        # but the upstream service doesn't support that; we use a wrapper instead.
        ExecStart = mkForce (
          let
            wrapper = pkgs.writeShellScript "silverbullet-api-gateway-wrapper" ''
              export SB_TOKEN=$(cat $CREDENTIALS_DIRECTORY/sb-token)
              exec ${cfg.package}/bin/silverbullet-api-gateway
            '';
          in "${wrapper}"
        );
      };
    };
  };
}
