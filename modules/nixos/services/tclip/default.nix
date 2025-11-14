{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.frgd.services.tclip;
in
{
  options.frgd.services.tclip = {
    enable = lib.mkEnableOption "Enable the tclip paste service";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = ''
        Nix package that provides the tclip daemon binary (tclipd).
        If left null you must provide a package via an overlay or set
        this option in your host configuration (recommended: use the
        upstream flake input and set this to
        inputs.tclip.packages.${config.system}.tclipd).
      '';
    };

    authKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Optional path to a file containing the Tailscale auth key to expose to tclipd.
        If unset and the sops module is enabled, the module will prefer
        `config.sops.secrets.tailscale_api_key.path` when available.
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/tclip/data";
      description = "Path where tclip will store its data (DATA_DIR).";
    };

    listenPort = lib.mkOption {
      type = lib.types.int;
      default = 8080;
      description = "Port used for any HTTP endpoints (only if you expose them locally).";
    };

    useStateDirectory = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "If true, enable systemd StateDirectory and DynamicUser for tclip.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true expose the configured listenPort via the NixOS firewall.";
    };

    extraServiceConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra attributes merged into systemd.serviceConfig for the tclip unit.";
    };
  };

  config = lib.mkIf cfg.enable (
    let
      pkg =
        if cfg.package != null then
          cfg.package
        else
          lib.throw (
            "services.tclip.package must be set when enabling the service.\n"
            + "Set it to e.g. inputs.tclip.packages.${config.system}.tclipd"
          );

      # Prefer explicit option, otherwise fall back to sops tailscale secret when present
      authKeyPath =
        if cfg.authKeyFile != null then
          cfg.authKeyFile
        else if
          lib.hasAttr "sops" config
          && lib.hasAttr "secrets" config.sops
          && lib.hasAttr "tailscale_api_key" config.sops.secrets
        then
          config.sops.secrets.tailscale_api_key.path
        else
          null;

      execStart =
        if authKeyPath != null then
          ''/bin/sh -c 'TS_AUTHKEY="$(cat ${authKeyPath})" exec ${pkg}/bin/tclipd' ''
        else
          "${pkg}/bin/tclipd";

      svc = {
        description = "tclip paste service";
        wantedBy = [ "multi-user.target" ];
        # Ensure system users are created before this unit runs
        unitConfig = {
          Wants = "systemd-sysusers.service";
          After = "systemd-sysusers.service";
        };
        serviceConfig = lib.mkMerge (
          [
            {
              ExecStart = execStart;
              Restart = "always";
              RestartSec = "30s";
              Environment = "DATA_DIR=${cfg.dataDir}";
              # Allow the tclip runtime user to read the tailscale secret which
              # will be owned by group `tailscale` (see modules/nixos/security/sops).
              SupplementaryGroups = "tailscale";
            }
          ]
          ++ (
            if cfg.useStateDirectory then
              [
                {
                  # Instead of using DynamicUser (which complicates supplementary
                  # groups on some systems), create and use a dedicated system user
                  # `tclip` and place it in the `tailscale` group so it can read the
                  # group-owned secret file created by the sops module.
                  User = "tclip";
                  Group = "tailscale";
                  StateDirectory = "tclip";
                }
              ]
            else
              [ ]
          )
          ++ [ cfg.extraServiceConfig ]
        );
      };

      # Create a dedicated runtime user so we can give it the tailscale group
      # membership and a stable identity (avoids DynamicUser/group race issues).
      users.users.tclip = {
        isSystem = true;
        description = "tclip runtime user";
        createHome = false;
        extraGroups = [ "tailscale" ];
        home = "/var/lib/tclip";
      };
    in
    {
      environment.systemPackages = [ pkg ];

      systemd.services.tclip = svc;

      # Optionally open the firewall for direct access
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.listenPort ];
    }
  );

}
