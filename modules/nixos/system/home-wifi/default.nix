{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.system.home-wifi;
in
{
  options.frgd.system.home-wifi = with types; {
    enable = mkBoolOpt false "Whether or not to manage home-wifi settings.";
    # networks: attribute set mapping an internal name to an object with
    # `ssid` (string) and `pskEnv` (the environment variable name inside the
    # secrets file that holds the pre-shared key).
    networks = mkOption {
      type = attrsOf (attrsOf types.str);
      default = { };
    };
  };

  config = mkIf cfg.enable {

    sops.secrets.wireless_env = { };
    # Use the new secrets handling introduced by wpa_supplicant/NixOS.
    # `secretsFile` replaces the deprecated `environmentFile` option.
    networking.wireless.secretsFile = config.sops.secrets.wireless_env.path;
    # Ensure a network manager is present so the configured networks are used.
    # Use mkDefault so hosts can opt out or choose a different manager.
    networking.networkmanager.enable = lib.mkDefault true;

    # Backwards-compatible default networks. Each entry is an attribute set
    # with `ssid` (the network SSID) and `pskEnv` (the variable name in the
    # secrets file that contains the PSK).
    # Hosts may override `frgd.system.home-wifi.networks` to declare their own
    # set of networks.
    networking.wireless.networks = lib.mkDefault {
      Mar10 = {
        ssid = "Mar10";
        pskEnv = "PSK_MAR10";
      };
      Martins5 = {
        ssid = "Martins-5";
        pskEnv = "PSK_Martins-5";
      };
      CBCoffice = {
        ssid = "CBCoffice";
        pskEnv = "PSK_CBCoffice";
      };
      WesternDevices = {
        ssid = "Western Devices";
        pskEnv = "PSK_WesternDevices";
      };
    };

    # Create declarative NetworkManager system-connections from the secrets
    # file on activation and at boot before NetworkManager starts. We emit a
    # small script that reads the secrets file and writes per-network
    # keyfiles into /etc/NetworkManager/system-connections/ so NM can manage
    # them as system connections.
    system.activationScripts.home-wifi = lib.mkAfter ''
      secrets_file='${toString config.sops.secrets.wireless_env.path}'
      mkdir -p /etc/NetworkManager/system-connections
      if [ -r "$secrets_file" ]; then
        # shellcheck disable=SC1090
        . "$secrets_file"
        ${lib.concatMapStringsSep "\n" (
          n:
          let
            ssid = n.ssid;
            pskEnv = n.pskEnv;
            fname = lib.escapeShellArg (lib.replaceStrings [ " " ] [ "_" ] ssid) + ".nmconnection";
          in
          ''
                    # network: ${ssid}
                    psk_var_name='${pskEnv}'
                    psk_value=$(eval "echo \"\$$psk_var_name\"")
                    if [ -n "$psk_value" ]; then
                      cat > /etc/NetworkManager/system-connections/${fname} <<NMEOF
            [connection]
            id=${ssid}
            type=wifi
            autoconnect=true

            [wifi]
            ssid=${ssid}
            mode=infrastructure

            [wifi-security]
            key-mgmt=wpa-psk
            psk=$psk_value

            [ipv4]
            method=auto

            [ipv6]
            method=auto
            NMEOF
                      chmod 600 /etc/NetworkManager/system-connections/${fname}
                    fi
          ''
        ) (builtins.attrValues (cfg.networks or { }))}

        # Try to reload NetworkManager so new connections are discovered
        systemctl try-restart NetworkManager || true
      fi
    '';

    # Ensure connections are present on first boot by providing a
    # oneshot systemd unit that runs before NetworkManager.service.
    # The unit is guarded with ConditionPathExists so it only runs when the
    # secrets file is present (deployed by sops). It writes the same files
    # as the activation script and sets secure permissions.
    systemd.services.home-wifi-generate = {
      description = "Generate NetworkManager system-connections from sops secrets";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          secrets_file='${toString config.sops.secrets.wireless_env.path}'
          mkdir -p /etc/NetworkManager/system-connections
          if [ -r "$secrets_file" ]; then
            # shellcheck disable=SC1090
            . "$secrets_file"
            ${lib.concatMapStringsSep "\n" (
              n:
              let
                ssid = n.ssid;
                pskEnv = n.pskEnv;
                fname = lib.escapeShellArg (lib.replaceStrings [ " " ] [ "_" ] ssid) + ".nmconnection";
              in
              ''
                                psk_var_name='${pskEnv}'
                                psk_value=$(eval "echo \"\$$psk_var_name\"")
                                if [ -n "$psk_value" ]; then
                                  cat > /etc/NetworkManager/system-connections/${fname} <<NMEOF
                [connection]
                id=${ssid}
                type=wifi
                autoconnect=true

                [wifi]
                ssid=${ssid}
                mode=infrastructure

                [wifi-security]
                key-mgmt=wpa-psk
                psk=$psk_value

                [ipv4]
                method=auto

                [ipv6]
                method=auto
                NMEOF
                                  chmod 600 /etc/NetworkManager/system-connections/${fname}
                                fi
              ''
            ) (builtins.attrValues (cfg.networks or { }))}
            # Attempt to reload NetworkManager so new connections are discovered
            systemctl try-restart NetworkManager || true
          fi
        '';
      };
      unitConfig = {
        Before = "NetworkManager.service";
        ConditionPathExists = toString config.sops.secrets.wireless_env.path;
      };
    };
    environment.systemPackages = [
      inputs.wifitui.packages.${pkgs.system}.default
    ];

  };
}
