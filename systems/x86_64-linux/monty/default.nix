{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    ./hardware.nix
  ];

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
  systemd.services.hermes-agent.environment.DISPLAY = ":99";

  system.activationScripts.hermes-unmanaged = lib.stringAfter [ "hermes-agent-setup" ] ''
    rm -f /var/lib/hermes/.hermes/.managed
  '';

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "hermes" &&
          action.lookup("unit") == "hermes-agent.service") {
        return polkit.Result.YES;
      }
    });
  '';

  # linger=true keeps the user manager (user@992.service) running at boot,
  # providing the dbus socket for systemctl --user calls during remote activation
  # (nixos-rebuild switch from p5810). Without it, user activation fails with
  # "Could not connect to bus" on headless hosts.
  # packages=mkForce suppresses the extraPackages from upstrea module, which
  # would trigger user activation to rebuild the profile — now safe, but still
  # redundant since those packages already reach the service via systemd PATH.
  users.users.hermes = {
    linger = true;
    packages = lib.mkForce [ ];
  };

  sops.secrets.monty_env = {
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
    mattermost = {
      enable = true;
      siteName = "Monty Chat";
      siteUrl = "https://chat.${tailnet}";
      host = "127.0.0.1";
      port = 8065;
      database = {
        create = true;
        name = "mattermost";
        user = "mattermost";
        peerAuth = true;
      };
    };

    hermes-agent = {
      enable = true;
      addToSystemPackages = true;
      extraDependencyGroups = [
        "firecrawl"
        "messaging"
        "web"
      ];
      extraPackages = with pkgs; [
        curl
        ffmpeg
        fluxbox
        forgejo-cli
        gh
        git
        jq
        nix
        novnc
        openssh
        x11vnc
        xauth
        xorg.xdpyinfo
        inputs.silverbullet-mcp.packages.${pkgs.system}.default
      ];
      environmentFiles = [ config.sops.secrets.monty_env.path ];
    };
  };

  # Hermes Dashboard — web UI, reverse-proxied by Caddy to monty.*.ts.net.
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
        ExecStart = "${effectivePackage}/bin/hermes dashboard --host 127.0.0.1 --port 9119 --no-open --skip-build";
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
    apps = { };
    archetypes = {
      server = enabled;
    };
    suites = { };
    system.boot = {
      enable = true;
      efi = true;
    };
    services = {
      caddy-proxy = {
        enable = true;
        hosts = {
          monty = {
            hostname = "monty.${tailnet}";
            backendAddress = "http://127.0.0.1:9119";
            useTailnet = true;
            extraConfig = ''
              handle_path /vnc/* {
                reverse_proxy localhost:6080
              }
              handle {
                reverse_proxy http://127.0.0.1:9119 {
                  header_up Host 127.0.0.1
                }
              }
            '';
          };
        };
      };
      tailscale = {
        autoconnect = {
          enable = true;
        };
      };
    };
    tools = {
      xvfb = enabled;
    };
  };
}
