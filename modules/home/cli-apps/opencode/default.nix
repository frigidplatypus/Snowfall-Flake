{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.opencode;

  # Shared bash permission rules. OpenCode matches last-rule-wins, and the
  # generated JSON sorts keys, so the more-specific `allow` entries (e.g.
  # "nix flake check") resolve after the broad `nix *`/wildcard `ask` rules.
  bashPermissions = {
    "git status" = "allow";
    "git diff" = "allow";
    "git log" = "allow";
    "git show" = "allow";
    "git branch" = "allow";
    "git add" = "ask";
    "git reset" = "ask";
    "git checkout" = "ask";
    "git commit" = "ask";
    "git commit *" = "ask";
    "git push" = "ask";
    "git push *" = "ask";
    pwd = "allow";
    ls = "allow";
    cat = "allow";
    head = "allow";
    tail = "allow";
    tree = "allow";
    rg = "allow";
    grep = "allow";
    find = "allow";
    "nix flake check" = "allow";
    "nix flake update" = "ask";
    "nix develop" = "allow";
    "nix search" = "allow";
    "nix shell" = "allow";
    treefmt = "allow";
    "nix build" = "ask";
    "nix run" = "ask";
    "nix *" = "ask";
    rm = "ask";
    "rm *" = "ask";
    mv = "ask";
    cp = "ask";
    mkdir = "ask";
    zfs = "ask";
    doas = "ask";
  };

  cavemanCfg = cfg.caveman;

  # Upstream base URL for the custom yolo-auto provider. Shared between the
  # opencode.json provider config and the caveman-proxy compat mount so the two
  # never drift out of sync.
  yoloAutoBase = "https://yolo-auto.com/v1";

  sharedCommands = {
    check = {
      template = "Run `nix flake check` to validate the flake and show any errors or warnings.";
      description = "Validate flake configuration";
    };
    format = {
      template = "Run `treefmt` to format all Nix files according to the project standards.";
      description = "Format Nix files";
    };
    build = {
      template = "Build the specified package using `nix build`. If no package is specified, build cliflux.";
      description = "Build Nix packages";
    };
    deploy = {
      template = "Deploy the NixOS configuration using `nixos-rebuild switch --flake .#<hostname>`. Ask which hostname to deploy if not specified.";
      description = "Deploy NixOS system";
    };
    update = {
      template = "Run `nix flake update` to update all flake inputs and show what changed.";
      description = "Update flake inputs";
    };
  };
in
{
  options.frgd.cli-apps.opencode = with types; {
    enable = mkBoolOpt false "Whether or not to enable OpenCode.";
    package = mkOpt types.package pkgs.opencode "The OpenCode package to use.";
    provider.enable = mkOption {
      type = types.bool;
      default = config.frgd.security.sops.enable;
      description = ''
        Whether to configure the personal yolo-auto provider. Defaults to
        whether home SOPS is enabled, since the provider reads its API key
        from an `opencode_yolo_auto_key` secret.
      '';
    };
    settings = mkOpt attrs { } "Extra OpenCode JSON settings, merged over shared defaults.";
    tui = mkOpt attrs { } "Extra OpenCode TUI settings (tui.json), merged over shared defaults.";
    defaultModel =
      mkOpt types.str "yolo-auto/qwen3.8-27b"
        "Default model (provider/model id) opencode starts with.";
    opencodeGo = {
      enable = mkBoolOpt false ''
        Whether to authenticate the built-in `opencode-go` subscription provider.
        The key is read from the `opencode_go_key` SOPS secret and wired into
        opencode.json (so it is declarative); auth.json is left untouched, which
        keeps interactive OAuth logins (openai, github-copilot) intact.
      '';
    };

    caveman = {
      enable = mkBoolOpt false ''
        Whether to install the caveman CLI and its bundled proxy/engine binaries
        so `caveman`, `caveman-proxy`, `caveman opencode`, `caveman stats`, ...
        are on PATH. OpenCode is NOT wrapped through the proxy; run `caveman
        opencode` manually to route a session through it on demand.
      '';
      package =
        mkOpt types.package pkgs.frgd.caveman
          "The caveman CLI (with bundled proxy/engine binaries) to use.";
      mode = mkOpt (types.nullOr types.str) null ''
        Caveman wrap mode to force (exported as CAVEMAN_MODE, e.g. "record",
        "compress", "shrink"). Null lets caveman pick its default.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.provider.enable || config.frgd.security.sops.enable;
        message = "frgd.cli-apps.opencode.provider.enable requires frgd.security.sops.enable (the provider reads its API key from SOPS).";
      }
      {
        assertion = !cfg.opencodeGo.enable || config.frgd.security.sops.enable;
        message = "frgd.cli-apps.opencode.opencodeGo.enable requires frgd.security.sops.enable (it reads opencode_go_key from SOPS).";
      }
    ];

    # Expose the caveman CLI (+ bundled proxy/engine binaries) directly so
    # `caveman stats`, `caveman status`, etc. work alongside the wrapped launch.
    home.packages = mkIf cavemanCfg.enable [ cavemanCfg.package ];

    programs.opencode = {
      enable = true;
      package = cfg.package;

      settings = mkMerge [
        {
          permission.bash = bashPermissions;
          command = sharedCommands;
          model = cfg.defaultModel;
        }
        (mkIf cfg.provider.enable {
          provider.yolo-auto = {
            npm = "@ai-sdk/openai-compatible";
            name = "Yolo-Auto";
            options = {
              baseURL = yoloAutoBase;
              apiKey = "{file:${config.sops.secrets.opencode_yolo_auto_key.path}}";
            };
            models."qwen3.8-27b" = {
              name = "qwen3.8-27b";
              limit = {
                context = 131072;
                output = 32768;
              };
            };
          };
        })
        (mkIf cfg.opencodeGo.enable {
          # Built-in provider: only the key source is overridden. auth.json is
          # left alone, so existing OAuth logins survive a rebuild.
          provider.opencode-go = {
            options.apiKey = "{file:${config.sops.secrets.opencode_go_key.path}}";
          };
        })
        cfg.settings
      ];

      tui = mkMerge [
        {
          theme = "gruvbox";
          plugin = [ "./herdr-tui-session.js" ];
        }
        cfg.tui
      ];

      commands = {
        "split-commits" = ./commands/split-commits.md;
        caveman = ./commands/caveman.md;
        "caveman-commit" = ./commands/caveman-commit.md;
        "caveman-compress" = ./commands/caveman-compress.md;
        "caveman-help" = ./commands/caveman-help.md;
        "caveman-review" = ./commands/caveman-review.md;
        "caveman-stats" = ./commands/caveman-stats.md;
      };
    };

    # The caveman proxy mutates opencode's config at launch (injects the
    # `caveman` MCP server and rewrites provider base URLs to the local proxy),
    # replacing the Home Manager symlinks with diverged regular files. On the
    # next switch Home Manager then has to back those files up before relinking;
    # with `backupFileExtension` set globally it refuses to clobber an existing
    # `*.backuphm`, aborting the whole activation. `force = true` makes HM
    # overwrite directly instead, and the proxy re-applies its mutations on the
    # next launch — so the files stay declarative-owned and self-healing.
    xdg.configFile = {
      "opencode/plugins/herdr-agent-state.js" = {
        source = ./plugins/herdr-agent-state.js;
        force = true;
      };
      "opencode/herdr-tui-session.js" = {
        source = ./plugins/herdr-tui-session.js;
        force = true;
      };
      # opencode.json and tui.json are created by programs.opencode; these
      # entries merge in `force` without disturbing their generated `source`.
      "opencode/opencode.json".force = true;
      "opencode/tui.json".force = true;
    };

    # The caveman-proxy only auto-mounts known providers (anthropic, openai,
    # openrouter, ...). A custom provider like yolo-auto has no compat mount, so
    # the proxy warns and passes traffic through with no compression. Teaching it
    # the upstream via `compat.<provider>.base_url` makes it mount and route it.
    # The proxy loads this from its default config path ~/.caveman/caveman.yaml
    # (CAVEMAN_HOME ?? ~/.caveman), which is runtime state outside $XDG_CONFIG_HOME,
    # so it must be a home.file rather than an xdg.configFile entry.
    home.file.".caveman/caveman.yaml" = mkIf (cavemanCfg.enable && cfg.provider.enable) {
      text = ''
        # Generated by the opencode Home Manager module — do not edit by hand.
        compat:
          "yolo-auto":
            base_url: ${yoloAutoBase}
      '';
    };

    # API keys materialized by sops-nix from the home SOPS file.
    sops.secrets.opencode_yolo_auto_key = mkIf cfg.provider.enable { };
    sops.secrets.opencode_go_key = mkIf cfg.opencodeGo.enable { };
  };
}
