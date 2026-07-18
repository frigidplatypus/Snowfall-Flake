{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
with lib.frgd;
let
  hermesPackage = config.services.hermes-agent.package.override {
    extraDependencyGroups = config.services.hermes-agent.extraDependencyGroups;
  };
  photonSidecarStorePath = "${hermesPackage}/share/hermes-agent/plugins/platforms/photon/sidecar";
  photonSidecarRuntimePath = "/var/lib/hermes/.hermes/photon-sidecar";
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
  systemd.services.hermes-agent.serviceConfig.NoNewPrivileges = lib.mkForce false;
  systemd.services.hermes-agent.serviceConfig.TimeoutStopSec = 210;
  systemd.services.hermes-agent.environment.DISPLAY = ":99";
  systemd.services.hermes-agent.environment.HERMES_HOME = "/var/lib/hermes/.hermes";
  # The packaged Photon sidecar lives in the read-only Nix store. Materialize
  # it under HERMES_HOME during activation, then bind-mount it over the bundled
  # path so the adapter still sees the expected location.
  systemd.services.hermes-agent.serviceConfig.BindPaths = [
    "${photonSidecarRuntimePath}:${photonSidecarStorePath}"
  ];

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

  environment.systemPackages = with pkgs; [
    frgd.sb
    # System tools for agent effectiveness
    go
    python3
    uv
    tmux
    fd
    eza
    yq
    gnumake
    cargo
    aria2
    sshfs
    htop
    dust
    procs
    bandwhich
    nodejs
  ];

  sops.secrets.monty_env = {
    owner = "hermes";
    group = "hermes";
    mode = "0440";
  };

  sops.secrets.beszel_monty_env = {
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
    # Remove managed-mode marker — config managed at runtime, not declaratively.
    rm -f /var/lib/hermes/.hermes/.managed

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

    mkdir -p /var/lib/hermes/.config/sbtask
    cat > /var/lib/hermes/.config/sbtask/config.yaml << 'SBTASK_EOF'
    spaces:
      main:
        space: "https://notes.fluffy-rooster.ts.net"
        default_page: "Tasks"
      household:
        space: "https://notes.fluffy-rooster.ts.net"
        default_page: "HouseholdTasks"
    active_space: main
    SBTASK_EOF
    chmod 600 /var/lib/hermes/.config/sbtask/config.yaml
    chown hermes:hermes /var/lib/hermes/.config/sbtask/config.yaml
  '';

  system.activationScripts.hermes-photon-sidecar-setup = lib.stringAfter [ "hermes-git-setup" ] ''
    mkdir -p /var/lib/hermes/.hermes

    staged="$(mktemp -d /var/lib/hermes/.hermes/photon-sidecar.XXXXXX)"
    trap 'rm -rf "$staged"' EXIT

    cp -r ${photonSidecarStorePath}/. "$staged"
    chmod -R u+w "$staged"

    if [ -d ${photonSidecarRuntimePath}/node_modules ]; then
      cp -r ${photonSidecarRuntimePath}/node_modules "$staged/node_modules"
      chmod -R u+w "$staged/node_modules"
    fi

    if [ ! -e "$staged/node_modules/.package-lock.json" ] || \
       [ "$staged/package-lock.json" -nt "$staged/node_modules/.package-lock.json" ]; then
      rm -rf "$staged/node_modules"
      HOME=/tmp ${pkgs.nodejs}/bin/npm ci --prefix "$staged" --no-audit --no-fund \
        || HOME=/tmp ${pkgs.nodejs}/bin/npm install --prefix "$staged" --no-audit --no-fund
    fi

    chown -R hermes:hermes "$staged"
    rm -rf ${photonSidecarRuntimePath}
    mv "$staged" ${photonSidecarRuntimePath}
    trap - EXIT
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

    # Pin postgresql version to prevent data directory changes on nixpkgs updates.
    # The mattermost module enables postgresql via database.create but doesn't pin
    # the version — without this, a nixpkgs bump can change the default version
    # (e.g. 15→17), creating a new empty data directory and orphaning the old one.
    postgresql.package = pkgs.postgresql_15;

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
        uv
        x11vnc
        xauth
        xorg.xdpyinfo
        xorg.xhost
        inputs.silverbullet-mcp.packages.${pkgs.system}.default
      ];
      environmentFiles = [ config.sops.secrets.monty_env.path ];
    };

    # Shared household Silverbullet — accessible at monty.fluffy-rooster.ts.net/notes
    silverbullet = {
      enable = true;
      package = pkgs.frgd.silverbullet;
      listenPort = 3002;
      listenAddress = "127.0.0.1";
      spaceDir = "/var/lib/hermes/workspace/household";
      user = "hermes";
      group = "hermes";
    };
  };

  # Hermes Desktop — headless desktop for browser-based auth (NotebookLM, etc.).
  # System service running as Hermes user. Depends on xvfb.service from frgd.tools.xvfb.
  # systemd.services.hermes-desktop = {
  #   description = "Headless desktop: fluxbox WM + x11vnc + noVNC proxy";
  #   after = [ "xvfb.service" ];
  #   wants = [ "xvfb.service" ];
  #   wantedBy = mkForce [ ];
  #
  #   environment.DISPLAY = ":99";
  #
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "hermes";
  #     Group = "hermes";
  #     ExecStart = "${pkgs.writeShellScript "hermes-desktop-start" ''
  #       # Preemptive cleanup: kill any processes left from a prior crash/restart
  #       # that didn't run ExecStop (e.g. wait -n exit before kill).
  #       # Avoid pkill/killall — not available in systemd's minimal PATH.
  #       for proc in fluxbox x11vnc novnc; do
  #         for pid in $(ls /proc/*/cmdline 2>/dev/null); do
  #           pid="''${pid%/cmdline}"; pid="''${pid#/proc/}"
  #           if grep -ql "$proc" "/proc/$pid/cmdline" 2>/dev/null; then
  #             kill "$pid" 2>/dev/null || true
  #           fi
  #         done
  #       done
  #       sleep 0.5
  #
  #       ${pkgs.fluxbox}/bin/fluxbox &
  #       ${pkgs.x11vnc}/bin/x11vnc -display :99 \
  #         -forever -shared -rfbport 5900 -localhost &
  #       ${pkgs.novnc}/bin/novnc --listen 127.0.0.1:6080 \
  #         --vnc localhost:5900 &
  #       # Block on first child death. systemd's Restart= recovers the whole stack.
  #       wait -n
  #     ''}";
  #     ExecStop = "${pkgs.writeShellScript "hermes-desktop-stop" ''
  #       # Kill processes by scanning /proc — avoids dependency on pkill/killall
  #       for proc in fluxbox x11vnc novnc; do
  #         for pid_dir in /proc/*/cmdline; do
  #           pid="''${pid_dir%/cmdline}"; pid="''${pid#/proc/}"
  #           if grep -ql "$proc" "/proc/$pid/cmdline" 2>/dev/null; then
  #             kill "$pid" 2>/dev/null || true
  #           fi
  #         done
  #       done
  #     ''}";
  #     Restart = "on-failure";
  #     RestartSec = "5s";
  #   };
  # };

  # NotebookLM MCP server — env vars for Chrome channel and auto-login.
  services.hermes-agent.mcpServers.notebooklm = {
    command = "npx";
    args = [ "notebooklm-mcp@latest" ];
    env = {
      BROWSER_CHANNEL = "chromium";
      AUTO_LOGIN_ENABLED = "true";
      DISPLAY = ":99";
    };
  };

  # Beszel MCP server — query system stats from the hub on racknerd.
  # Env vars (BESZEL_URL, BESZEL_EMAIL, BESZEL_PASSWORD) in beszel_monty_env SOPS secret.
  services.hermes-agent.mcpServers.beszel = {
    command = "bash";
    args = [ "/var/lib/hermes/.hermes/scripts/run-beszel-mcp.sh" ];
  };

  # Miniflux MCP — RSS reader management.
  # Tokens from MINIFLUX_URL, MINIFLUX_API_KEY in .env
  services.hermes-agent.mcpServers.miniflux = {
    command = "bash";
    args = [ "/var/lib/hermes/.hermes/scripts/run-miniflux-mcp.sh" ];
  };

  # Paperless MCP — document management.
  # Tokens from PAPERLESS_URL, PAPERLESS_TOKEN in .env
  services.hermes-agent.mcpServers.paperless = {
    command = "bash";
    args = [ "/var/lib/hermes/.hermes/scripts/run-paperless-mcp.sh" ];
  };

  # Audiobookshelf MCP — audiobook/podcast library management.
  # Tokens from ABS_BASE_URL, ABS_API_KEY in .env
  services.hermes-agent.mcpServers.audiobookshelf = {
    command = "bash";
    args = [ "/var/lib/hermes/.hermes/scripts/run-audiobookshelf-mcp.sh" ];
  };

  # UniFi Network MCP — query client devices (MAC, IP, hostname) for power-loss recovery.
  services.hermes-agent.mcpServers.unifi-network = {
    command = "uvx";
    args = [ "unifi-network-mcp" ];
    env = {
      UNIFI_HOST = "192.168.0.14";
      UNIFI_PORT = "8443";
      UNIFI_USERNAME = "readonly";
      UNIFI_PASSWORD = "LZmkeDqsmHLxxjjiCT4JRavg";
      UNIFI_VERIFY_SSL = "false";
    };
  };

  # Hermes Dashboard — web UI, reverse-proxied by Caddy to monty.*.ts.net.
  systemd.services.hermes-dashboard =
    let
      effectivePackage = hermesPackage;
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

  # Shared household Silverbullet — systemd overrides.
  # The base service is created by services.silverbullet above; these settings merge in.
  systemd.services.silverbullet = {
    path = with pkgs; [
      git
      openssh
      chromium
    ];
    environment = {
      SB_CHROME_PATH = "${pkgs.chromium}/bin/chromium-browser";
    };
    serviceConfig = {
      # Override the nixpkgs module's StateDirectory which would only create
      # /var/lib/household — we need the full nested path.
      StateDirectory = lib.mkForce "hermes/workspace/household";
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
      borgmatic = {
        enable = true;
        autoInit.enable = true;
        directories = [ "/var/lib/hermes" ];
        repositories = [ "ssh://***@d6mzjh1m.repo.borgbase.com/./repo" ];
        notifications.pushover = {
          enable = true;
          apiToken = "aphv2rpofwt7uco51vn672hfkfvagn";
          userKey = "ub1izqc8tz9ps35nhnvt5zznqdsmav";
          onError = true;
        };
      };
    };
    tools = {
      xvfb = enabled;
      nix-ld = enabled;
    };
  };
}
