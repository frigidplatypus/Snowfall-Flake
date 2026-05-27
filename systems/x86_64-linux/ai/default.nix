{
  lib,
  modulesPath,
  config,
  pkgs,
  inputs,
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

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "hermes" &&
          action.lookup("unit") == "hermes-agent.service") {
        return polkit.Result.YES;
      }
    });
  '';

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
        x11vnc
        inputs.silverbullet-mcp.packages.${pkgs.system}.default
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

  systemd.services.x11vnc = {
    description = "VNC server for Xvfb display :99";
    after = [ "xvfb.service" ];
    wants = [ "xvfb.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -forever -shared -display :99 -rfbport 5900";
      Restart = "on-failure";
      RestartSec = 3;
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
  }; # ← closes frgd

  # Patch hermes-agent to make dashboard_auth import optional.
  # Upstream pyproject.toml omits "hermes_cli.*" from find.packages,
  # so dashboard_auth subpackage is excluded from the built wheel.
  nixpkgs.overlays = lib.mkAfter [
    (final: prev: {
      hermes-agent = prev.hermes-agent.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          patch_dir="$out/lib/site-patches/hermes_cli"
          mkdir -p "$patch_dir"
          cp "${prev.hermes-agent.hermesVenv}/lib/python3.12/site-packages/hermes_cli/__init__.py" "$patch_dir/"
          cp "${prev.hermes-agent.hermesVenv}/lib/python3.12/site-packages/hermes_cli/web_server.py" "$patch_dir/"
          ${pkgs.python3}/bin/python3 -c "
path = '$patch_dir/web_server.py'
content = open(path).read()
old = 'from hermes_cli.dashboard_auth.routes import router as _dashboard_auth_router  # noqa: E402\napp.include_router(_dashboard_auth_router)'
new = '''try:
    from hermes_cli.dashboard_auth.routes import router as _dashboard_auth_router  # noqa: E402
    app.include_router(_dashboard_auth_router)
except ModuleNotFoundError:
    pass'''
assert old in content, 'Could not find dashboard_auth import in web_server.py'
content = content.replace(old, new)
open(path, 'w').write(content)
print('dashboard_auth: import patched to optional (no auth)')

          wrapProgram $out/bin/hermes --prefix PYTHONPATH : "$patch_dir"
        '';
      });
    })
  ];
}
