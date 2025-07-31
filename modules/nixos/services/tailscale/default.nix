{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.tailscale;
in
{
  options.frgd.services.tailscale = with types; {
    enable = mkBoolOpt false "Whether or not to configure Tailscale";
    autoconnect = {
      enable = mkBoolOpt false "Whether or not to enable automatic connection to Tailscale";
    };
    tailscaleAuth.enable = mkBoolOpt false "Whether or not to enable Tailscale authentication";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ tailscale ];

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets.tailscale_api_key.path;
      permitCertUid = "caddy";

      extraUpFlags = [
        "--ssh"
        "--accept-dns"
        "--accept-routes=false"
      ];
    };

    systemd.services.tailscale = {
      restartIfChanged = false;
      # You can also add other systemd service options here if needed,
      # but for preventing restarts, this is the main one.
      # Example of other options (usually not needed to specify if 'services.tailscale.enable' is true):
      # description = "Tailscale node agent";
      # wantedBy = [ "multi-user.target" ];
      # serviceConfig.ExecStart = "${pkgs.tailscale}/bin/tailscaled";
    };
    services.tailscaleAuth = mkIf cfg.tailscaleAuth.enable {
      enable = true;
      user = config.services.caddy.user;
      group = config.services.caddy.group;
    };

    networking = {
      firewall = {
        trustedInterfaces = [ config.services.tailscale.interfaceName ];

        allowedUDPPorts = [ config.services.tailscale.port ];

        # Strict reverse path filtering breaks Tailscale exit node use and some subnet routing setups.
        checkReversePath = "loose";
      };

      networkmanager.unmanaged = [ "tailscale0" ];
    };

    systemd.services.tailscale-autoconnect = mkIf cfg.autoconnect.enable {
      description = "Automatic connection to Tailscale";

      # Make sure tailscale is running before trying to connect to tailscale
      after = [
        "network-pre.target"
        "tailscale.service"
      ];
      wants = [
        "network-pre.target"
        "tailscale.service"
      ];
      wantedBy = [ "multi-user.target" ];

      # Set this service as a oneshot job
      serviceConfig.Type = "oneshot";

      # Have the job run this shell script
      script = with pkgs; ''
                # Wait for tailscaled to settle
                sleep 2

                # Check if we are already authenticated to tailscale
                status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
                if [ $status = "Running" ]; then # if so, then do nothing
                  exit 0
                fi

                # Otherwise authenticate with tailscale
                ${tailscale}/bin/tailscale up -authkey "$(cat ${config.sops.secrets.tailscale_api_key.path})"

        #         ${tailscale}/bin/tailscale up --authkey (cat ${config.sops.secrets.tailscale_api_key.path})
      '';
    };
  };
}
