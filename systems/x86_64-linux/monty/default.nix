{
  lib,
  pkgs,
  config,
  inputs,
  ...,
}:
with lib;
with lib.frgd;
let
  # Wrapper for notebooklm-mcp that patches --no-sandbox into Chrome launch args.
  # Required when NoNewPrivileges is set — Chromium can't use its sandbox.
  notebooklm-wrapper = pkgs.writeShellScript "notebooklm-wrapper" ''
    set -euo pipefail
    PROFILE_DIR="''${HOME}/.local/share/notebooklm-mcp/chrome_profile"

    # Clean stale Singleton locks
    if [[ -d "$PROFILE_DIR" ]]; then
      for lock in SingletonLock SingletonCookie SingletonSocket; do
        lockfile="''${PROFILE_DIR}/''${lock}"
        if [[ -L "$lockfile" || -f "$lockfile" ]]; then
          lock_target=$(readlink "$lockfile" 2>/dev/null || echo "")
          lock_pid=""
          if [[ "$lock_target" =~ ^.*-([0-9]+)$ ]]; then
            lock_pid="''${BASH_REMATCH[1]}"
          fi
          if [[ -n "$lock_pid" ]] && kill -0 "$lock_pid" 2>/dev/null; then
            proc_name=$(ps -p "$lock_pid" -o comm= 2>/dev/null || echo "")
            case "$proc_name" in *chrom*|*chrome*) ;; *) rm -f "$lockfile" ;; esac
          else
            rm -f "$lockfile"
          fi
        fi
      done
      for dir in /tmp/org.chromium.Chromium.*/; do
        [[ -d "$dir" ]] || continue; rm -rf "$dir"
      done
    fi

    # Patch --no-sandbox into the MCP server's Chrome launch args (idempotent)
    CANDIDATE=$(find "''${HOME}/.npm/_npx" -path '*/notebooklm-mcp/dist/session/shared-context-manager.js' 2>/dev/null | head -1)
    if [[ -n "$CANDIDATE" ]] && [[ -f "$CANDIDATE" ]]; then
      if ! grep -q -- '--no-sandbox' "$CANDIDATE" 2>/dev/null; then
        sed -i 's/"--no-default-browser-check",/"--no-default-browser-check",\n                "--no-sandbox",/' "$CANDIDATE"
      fi
    fi

    exec npx notebooklm-mcp@latest
  '';
in
{
  imports = [
    ./hardware.nix
  ];

  security.sudo.extraRules = [
    {
      users = [ "hermes" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Run xvfb as hermes too — otherwise MIT-MAGIC-COOKIE is owned by root
  # and the desktop processes (also User=hermes) can't connect to :99.
  systemd.services.xvfb.serviceConfig.User = "hermes";

  # NoNewPrivileges prevents sudo from working — must be false
  # so the agent can run privileged commands via sudo.
  systemd.services.hermes-agent.serviceConfig.NoNewPrivileges = false;
  systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 210;
  systemd.services.hermes-agent.environment.DISPLAY = ":99";

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.user == "hermes" &&
          action.lookup("unit") == "hermes-agent.service") {
        return polkit.Result.YES;
      }
    });
  '';

  # packages=mkForce suppresses the extraPackages from upstream module, which
  # would trigger user activation to rebuild the profile — redundant since
  # those packages already reach the service via systemd PATH.
  users.users.hermes = {
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
        chromium
        curl
        ffmpeg
        fluxbox
        forgejo-cli
        gh
        git
        jq
        nix
        nodejs
        novnc
        openssh
        x11vnc
        xauth
        xorg.xdpyinfo
        xorg.xhost
        inputs.silverbullet-mcp.packages.${pkgs.system}.default
      ];
      environmentFiles = [ config.sops.secrets.monty_env.path ];
    };
  };

  # Hermes Desktop — headless desktop for browser-based auth (NotebookLM, etc.).
  # System service running as Hermes user. Depends on xvfb.service from frgd.tools.xvfb.
  systemd.services.hermes-desktop = {
    description = "Headless desktop: fluxbox WM + x11vnc + noVNC proxy";
    after = [ "xvfb.service" ];
    wants = [ "xvfb.service" ];
    wantedBy = [ "multi-user.target" ];

    environment.DISPLAY = ":99";

    serviceConfig = {
      Type = "simple";
      User = "hermes";
      Group = "hermes";
      ExecStart = "${pkgs.writeShellScript "hermes-desktop-start" ''
        ${pkgs.fluxbox}/bin/fluxbox &
        ${pkgs.x11vnc}/bin/x11vnc -display :99 \
          -forever -shared -rfbport 5900 -localhost &
        ${pkgs.novnc}/bin/novnc --listen 127.0.0.1:6080 \
          --vnc localhost:5900 &
        # Block on first child death. systemd's Restart= recovers the whole stack.
        wait -n
      ''}";
      ExecStop = "${pkgs.writeShellScript "hermes-desktop-stop" ''
        pkill -f "novnc.*6080" 2>/dev/null || true
        pkill x11vnc 2>/dev/null || true
        pkill fluxbox 2>/dev/null || true
      ''}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # NotebookLM MCP server — env vars for Chrome channel and auto-login.
  services.hermes-agent.mcpServers.notebooklm = {
    command = "${notebooklm-wrapper}";
    env = {
      BROWSER_CHANNEL = "chromium";
      AUTO_LOGIN_ENABLED = "true";
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
