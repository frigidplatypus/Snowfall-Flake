{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  networking.firewall.enable = false;

  security.sudo.extraRules = [
    {
      users = [ "hermes" ];
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl restart hermes-agent";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl stop hermes-agent";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl start hermes-agent";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl status hermes-agent";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl reset-failed hermes-agent";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 210;

  sops.secrets.hermes_env = {
    owner = "hermes";
    group = "hermes";
    mode = "0440";
  };

  sops.secrets.git_server_ssh_key = {
    owner = "hermes";
    group = "hermes";
    mode = "0600";
  };

  system.activationScripts.hermes-git-setup = lib.stringAfter [ "hermes-agent-setup" ] ''
        mkdir -p /var/lib/hermes/.ssh
        chmod 700 /var/lib/hermes/.ssh
        chown hermes:hermes /var/lib/hermes/.ssh

        cp ${config.sops.secrets.git_server_ssh_key.path} /var/lib/hermes/.ssh/id_ed25519
        chmod 600 /var/lib/hermes/.ssh/id_ed25519
        chown hermes:hermes /var/lib/hermes/.ssh/id_ed25519

        cat > /var/lib/hermes/.ssh/config << 'SSH_EOF'
    Host git.fluffy-rooster.ts.net
      Hostname git.fluffy-rooster.ts.net
      User git
      IdentityFile /var/lib/hermes/.ssh/id_ed25519
      StrictHostKeyChecking no
    SSH_EOF
        chmod 600 /var/lib/hermes/.ssh/config
        chown hermes:hermes /var/lib/hermes/.ssh/config

        cat > /var/lib/hermes/.gitconfig << 'GIT_EOF'
    [user]
      name = Hermes Agent
      email = hermes@fluffy-rooster.ts.net
    [init]
      defaultBranch = main
    [pull]
      rebase = true
    [push]
      autoSetupRemote = true
    GIT_EOF
        chmod 644 /var/lib/hermes/.gitconfig
        chown hermes:hermes /var/lib/hermes/.gitconfig
  '';

  services = {
    hermes-agent = {
      enable = true;
      addToSystemPackages = true;
      extraDependencyGroups = [
        "messaging"
        "web"
      ];
      extraPackages = with pkgs; [
        curl
        jq
        nix
        forgejo-cli
        openssh
      ];
      environmentFiles = [ config.sops.secrets.hermes_env.path ];
      settings = { };
    };

    guacamole-server = {
      enable = true;
      host = "127.0.0.1";
    };

    guacamole-client = {
      enable = true;
      enableWebserver = true;
      settings = {
        guacd-hostname = "127.0.0.1";
        guacd-port = 4822;
      };
      userMappingXml = pkgs.writeText "user-mapping.xml" ''
        <?xml version="1.0" encoding="UTF-8"?>
        <user-mapping>
          <authorize username="guacuser" password="5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" encoding="sha256">
            <connection name="AI Desktop">
              <protocol>vnc</protocol>
              <param name="hostname">127.0.0.1</param>
              <param name="port">5900</param>
            </connection>
          </authorize>
        </user-mapping>
      '';
    };
  };

  # Hermes Dashboard — web UI, reverse-proxied by Caddy.
  # Uses the same effectivePackage as the gateway (includes messaging + web deps).
  systemd.services.hermes-dashboard =
    let
      effectivePackage = config.services.hermes-agent.package.override {
        extraDependencyGroups = config.services.hermes-agent.extraDependencyGroups;
      };
    in
    {
      description = "Hermes Agent Dashboard";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network-online.target"
        "hermes-agent.service"
      ];
      wants = [ "network-online.target" ];

      environment = {
        HERMES_HOME = "/var/lib/hermes/.hermes";
        HERMES_MANAGED = "true";
      };

      serviceConfig = {
        User = "hermes";
        Group = "hermes";
        ExecStart = "${effectivePackage}/bin/hermes dashboard --host 127.0.0.1 --port 9119 --no-open --tui";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = false;
        ReadWritePaths = [ "/var/lib/hermes" ];
        PrivateTmp = true;
      };
    };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    tools.node = {
      enable = true;
      pkg = pkgs.nodejs_24;
    };
    apps.chromium = enabled;
    tools.xvfb = enabled;
    tools.nix-ld = enabled;
    services.caddy-proxy = {
      enable = true;
      hosts = {
        ai = {
          hostname = "ai.${tailnet}";
          # Dashboard validates Host header against its bound address.
          # Override via handle block so Host arrives as 127.0.0.1.
          backendAddress = "http://127.0.0.1:9119";
          useTailnet = true;
          extraConfig = ''
            handle {
              reverse_proxy http://127.0.0.1:9119 {
                header_up Host 127.0.0.1
              }
            }
          '';
        };
      };
    };
  };
}
