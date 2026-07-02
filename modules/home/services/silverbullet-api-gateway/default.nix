{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

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
      default = pkgs.silverbullet-api-gateway;
      defaultText = literalExpression "pkgs.silverbullet-api-gateway";
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
      description = "Default page when no `page` form param sent in POST request (SB_PAGE).";
    };

    tokenFile = mkOption {
      type = nullOr path;
      default = null;
      description = ''
        Path to a file containing the SB_TOKEN. Use sops-nix to
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
      type = nullOr str;
      default = "\n";
      description = "Separator string between appended entries (SEPARATOR). Null to use binary default.";
    };

    journalPattern = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Template for journal pages when `page=journal` in POST request.
        [DATE] replaced with YYYY-MM-DD. Defaults to "Journal/[DATE].md" in binary.
      '';
    };

    inboxPage = mkOption {
      type = nullOr str;
      default = null;
      description = ''
        Page name when `page=inbox` in POST request.
        Defaults to "inbox" in binary.
      '';
    };

    port = mkOption {
      type = port;
      default = 8080;
      description = "Port the gateway listens on (note: binary hardcodes 8080, this option reserves the port only).";
    };
  };

  config = mkIf cfg.enable {
    services.silverbullet-api-gateway = {
      enable = true;
      package = cfg.package;
      sbUrl = cfg.url;
      sbToken = if cfg.tokenFile != null then "loading-from-file" else (cfg.token or "");
      sbPage = cfg.page;
      dataPattern = cfg.dataPattern;
      separator = cfg.separator;
      journalPattern = cfg.journalPattern;
      inboxPage = cfg.inboxPage;
    };

    # Load token from file if tokenFile is set (via systemd LoadCredential)
    systemd.user.services.silverbullet-api-gateway = mkIf (cfg.tokenFile != null) {
      Service = {
        LoadCredential = "sb-token:${cfg.tokenFile}";
        ExecStart = mkForce (
          let
            wrapper = pkgs.writeShellScript "silverbullet-api-gateway-wrapper" ''
              export SB_TOKEN=$(cat $CREDENTIALS_DIRECTORY/sb-token)
              exec ${cfg.package}/bin/silverbullet-api-gateway
            '';
          in
          "${wrapper}"
        );
      };
    };
  };
}
