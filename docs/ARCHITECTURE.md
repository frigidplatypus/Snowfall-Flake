# Architecture Reference

## Directory Layout

```
flake.nix                          # Flake entry point — inputs + Snowfall Lib setup
flake.lock                         # Pinned input revisions

systems/<system>/<host>/           # NixOS/darwin/ISO host configs
  ├── default.nix                  #   Main host configuration
  ├── hardware.nix                 #   Hardware-specific config (optional)
  ├── disko.nix                    #   Disk partitioning (optional)
  └── README.md                    #   Host-specific notes (optional)

homes/<system>/<user>@<host>/      # Home Manager configs
  └── default.nix

modules/nixos/                     # NixOS module tree (auto-discovered)
  ├── archetypes/                  #   Machine archetypes (workstation, server, lxc, vm, gaming)
  ├── suites/                      #   Suite bundles (common, common-slim, desktop, development, etc.)
  ├── apps/                        #   Desktop application modules
  ├── cli-apps/                    #   CLI tool modules
  ├── desktop/                     #   Desktop environment modules
  ├── hardware/                    #   Hardware configuration modules
  ├── home/                        #   Home directory / state modules
  ├── nix/                         #   Nix daemon configuration
  ├── security/                    #   SOPS, SSH, GPG, ACME, doas, keyring
  ├── services/                    #   Service modules (50+ services)
  ├── system/                      #   System-level config (boot, zfs, locale, time, fonts)
  ├── tools/                       #   Utility tool modules
  ├── user/                        #   User account configuration
  └── virtualization/              #   Docker, libvirtd

modules/home/                      # Home Manager module tree
  ├── apps/                        #   Desktop app configs
  ├── cli-apps/                    #   CLI tool configs (neovim, ranger, fish, tmux, etc.)
  ├── desktop/                     #   Desktop configs
  ├── security/                    #   Home-level security
  ├── services/                    #   User services
  ├── suites/                      #   Home Manager suites
  ├── tools/                       #   Tool configs
  └── user/                        #   User-level configs

packages/<name>/                   # Custom packages (10 total)
  └── default.nix

overlays/<name>/                   # Package overlays
  └── default.nix

lib/                               # Library helpers
  ├── module/default.nix           #   mkOpt, mkBoolOpt, enabled, disabled, tailnet, font
  └── deploy/default.nix           #   mkDeploy — deploy-rs config generator

scripts/                           # Bootstrap and utility scripts
  ├── bootstrap.sh
  ├── clone_nvim.sh
  ├── github_remote.sh
  └── prep_disks.sh

assets/                            # Static assets (wallpaper, etc.)
```

## The `frgd` Option Namespace

All custom options live under `frgd.<category>.<name>` to avoid conflicts with upstream NixOS options. The namespace (`frgd`) is set in `flake.nix`:

```nix
snowfall = {
  meta.name = "frgd";
  namespace = "frgd";
};
```

### Categories

| Category | Path | Description |
|----------|------|-------------|
| `apps` | `modules/nixos/apps/` | Desktop application toggles (firefox, vscode, steam, signal, etc.) |
| `archetypes` | `modules/nixos/archetypes/` | Machine archetypes that bundle suites + base config |
| `cli-apps` | `modules/nixos/cli-apps/` + `modules/home/cli-apps/` | CLI tool configuration |
| `desktop` | `modules/nixos/desktop/` | Desktop environment modules (hyprland, gnome, plasma, niri, cosmic, xfce) |
| `hardware` | `modules/nixos/hardware/` | Hardware-specific modules (audio, fingerprint, networking, storage) |
| `home` | `modules/nixos/home/` | Home directory management |
| `nix` | `modules/nixos/nix/` | Nix daemon config |
| `security` | `modules/nixos/security/` | Security modules (sops, ssh, doas, gpg, acme, keyring) |
| `services` | `modules/nixos/services/` | Service modules (50+ services) |
| `suites` | `modules/nixos/suites/` | Suite bundles that enable groups of frgd modules |
| `system` | `modules/nixos/system/` | System-level config (boot, zfs, zram, locale, time, fonts, env) |
| `tools` | `modules/nixos/tools/` | Utility tool modules (git, ssh, direnv, etc.) |
| `user` | `modules/nixos/user/` | User account config |
| `virtualization` | `modules/nixos/virtualization/` | Virtualization (docker, libvirtd) |

### Naming Conventions

- **Directory names:** kebab-case (e.g., `zfs-replication`, `beszel-agent`, `caddy-proxy`)
- **Option names:** camelCase (e.g., `githubAccessToken`, `autoSnapshot`, `backendAddress`)
- **Module files:** always `default.nix` (Snowfall convention)

## The Archetype System

Archetypes are the top-level machine classifier. Each host picks exactly one (or none):

```
frgd.archetypes.workstation  →  enables common + desktop + development suites
frgd.archetypes.server       →  enables common-slim suite
frgd.archetypes.lxc          →  container-optimized config + beszel + tailscale autoconnect
frgd.archetypes.vm           →  QEMU guest agent + boot config
frgd.archetypes.gaming       →  defined but unused
```

The archetype module sets `frgd.suites.*` options, which in turn enable individual `frgd.*` modules. This creates a clean hierarchy:

```
archetype → suites → modules
```

### Example: workstation archetype

```nix
# modules/nixos/archetypes/workstation/default.nix
config = mkIf cfg.enable {
  frgd = {
    suites.common = enabled;      # → full common config (gui tools, dev tools, etc.)
    suites.desktop = enabled;     # → desktop environment + apps + printing
    suites.development = enabled;  # → development tools
  };
};
```

## The Suite System

Suites are bundles of `frgd.*` module enables. They sit between archetypes and individual modules:

| Suite | What it enables |
|-------|----------------|
| `common` | Everything in common-slim + desktop addons, more apps |
| `common-slim` | nix config, cli tools (nh, git, comma, direnv, misc), services (openssh, tailscale, avahi, syncthing, beszel-agent), security (sops, doas), system (boot, fonts, locale, time, xkb) |
| `desktop` | Desktop env selection + apps (1password, vlc, firefox, vscode) + printing |
| `development` | Development tools |
| `art` | Creative tools |
| `video` | Video production tools |
| `music` | Audio production tools |
| `games` | Gaming tools |
| `emulation` | Emulation tools |
| `social` | Social apps |
| `installer` | ISO installer tools |

Individual suites have sub-options for choosing desktop environments:

```nix
frgd.suites.desktop = {
  enable = true;
  hyprland = true;   # or gnome, plasma, xfce, cosmic, niri
};
```

## Lib Helpers

### `lib/module/default.nix`

Exposed via `lib.frgd` for use in all modules:

| Helper | Signature | Description |
|--------|-----------|-------------|
| `mkOpt` | `type → default → description → option` | Create a typed option |
| `mkOpt'` | `type → default → option` | Create option without description |
| `mkBoolOpt` | `default → description → option` | Create a boolean option (curried `mkOpt types.bool`) |
| `mkBoolOpt'` | `default → option` | Boolean option without description |
| `enabled` | `{ enable = true; }` | Quick-enable shorthand |
| `disabled` | `{ enable = false; }` | Quick-disable shorthand |
| `tailnet` | `"fluffy-rooster.ts.net"` | Tailscale tailnet name |
| `tsidpUrl` | `"https://idp.fluffy-rooster.ts.net"` | Tailscale IDP URL |
| `font` | `"MononokiNerdFont"` | Preferred font |
| `font-mono` | `"${font}Mono"` | Monospace font |
| `font-propo` | `"${font}Propo"` | Proportional font |
| `icon-theme` | `"Gruvbox-Plus-Dark"` | Default icon theme |
| `flakeRoot` | `self.outPath` | Flake root path |

### `lib/deploy/default.nix`

```nix
lib.mkDeploy { inherit (inputs) self; }
```

Generates deploy-rs node configuration for all NixOS hosts, excluding `p5810` and `t480`. Each node:
- Uses root SSH user (or custom user from `frgd.user.name`)
- Respects `frgd.security.doas.enable` for doas-based sudo
- Hostname defaults to the host attribute name

## Code Style Guide

### Module Template

```nix
{ lib, config, pkgs, ... }:
with lib;
with lib.frgd;
let
  cfg = config.frgd.<category>.<name>;
in
{
  options.frgd.<category>.<name> = with types; {
    enable = mkBoolOpt false "Description.";
    # other options...
  };

  config = mkIf cfg.enable {
    # configuration here
  };
}
```

### Rules

1. **Always** `with lib; with lib.frgd;` at the top of every module
2. **Naming:** kebab-case for dirs, camelCase for options (e.g., `mkOption` called `zfsReplication`, dir is `zfs-replication/`)
3. **Config gating:** always `config = mkIf cfg.enable { ... }`
4. **Conditional merges:** use `mkMerge [ (mkIf cond1 { ... }) (mkIf cond2 { ... }) ]`, never `mkIf ... // mkIf ...` (preserves module system conditions)
5. **Structure:** `let cfg = config.frgd.<module>; in` with `inherit` for clarity
6. **Formatting:** run `nixfmt` before commits
7. **Types:** prefer explicit option types; `throw` early on invalid input
8. **Comments:** concise for non-obvious logic; no noisy comments

## Flake Inputs

Key inputs and their purpose:

| Input | Source | Purpose |
|-------|--------|---------|
| `nixpkgs` | flakehub (0.1 channel) | Main nixpkgs (unstable) |
| `stable-nixpkgs` | flakehub (*) | Stable nixpkgs for overlays |
| `home-manager` | release-26.05 | User-level package management |
| `snowfall-lib` | GitHub (anntnzrb fork) | Flake auto-discovery framework |
| `snowfall-flake` | GitHub | Snowfall overlay for package/flake outputs |
| `sops-nix` | GitHub | Secrets management (AGE encryption) |
| `deploy-rs` | GitHub | Remote deployment tooling |
| `disko` | GitHub | Disk partitioning at build time |
| `nixos-hardware` | GitHub | Hardware-specific NixOS configs |
| `nixos-generators` | GitHub | ISO/image generation |
| `nix-colors` | GitHub | Color scheme library |
| `nix-index-database` | GitHub | `command-not-found` database |
| `nix-flatpak` | GitHub | Flatpak integration |
| `neovim` | GitHub (frigidplatypus) | Custom Neovim config |
| `golink` | GitHub | Tailscale short links |
| `tclip` | GitHub | Tailscale pastebin |
| `hermes` | GitHub | Hermes AI agent |
| `niri-flake` | GitHub | Niri compositor |
| `nr` | Forgejo (self-hosted) | Go rewrite of the nr deploy script |
| `email-to-miniflux` | Forgejo (self-hosted) | Email to RSS bridge |
| `silverbullet-mcp` | Forgejo (self-hosted) | Silverbullet MCP server |

## Custom Packages

Located in `packages/`:

| Package | Description |
|---------|-------------|
| `godap` | Go-based DAP server |
| `lsq` | Lightweight SQL tool |
| `markdown-styles` | Markdown CSS styles |
| `mdpdf` | Markdown to PDF converter |
| `numara` | Number station tool |
| `osk-toggle` | On-screen keyboard toggle |
| `sb` | Silverbullet CLI |
| `silverbullet` | Silverbullet server (custom build) |
| `unifly` | UniFi controller helper |
| `wakeonlan_script` | Wake-on-LAN utility |

## Secret Management

- **Tool:** `sops-nix` with AGE encryption
- **Key file:** `/sops/keys.txt` (Linux) or `~/.config/sops/age/keys.txt` (macOS)
- **Secret files:**
  - `modules/nixos/security/sops/secrets.yaml` — NixOS-level secrets
  - `modules/home/security/sops/secrets.yaml` — Home Manager-level secrets
- **Access control:** Per-host key-based access. Each host must have its public key in the `.secrets.yaml` to decrypt its secrets.
- **Edit:** Always use `sops edit`, never a text editor on encrypted files.

## Flake Outputs

Snowfall Lib automatically generates these outputs:

| Output | Structure | Count |
|--------|-----------|-------|
| `nixosConfigurations.<host>` | Per host | 24 |
| `homeConfigurations.<user>@<host>` | Per user+host | 14 |
| `darwinConfigurations.<host>` | Darwin hosts | 1 (W12-1246) |
| `packages.x86_64-linux.<name>` | Custom packages | 10 |
| `overlays.default` | Package overlays | 1 (stable-packages) |
| `nixosModules.default` | Module namespace | Auto |
| `homeModules.default` | HM namespace | Auto |
| `checks.x86_64-linux` | Deploy checks | Wired via deploy-rs |

## ISO Images

Located in `systems/x86_64-iso/` for nixos-generators:

| ISO | Description |
|-----|-------------|
| `gui` | Desktop ISO with GUI environment |
| `minimal` | Minimal ISO |
| `proxmox-install` | ISO for Proxmox installation |

## Known Gaps

See also `AGENTS.md` for internal notes.

- **No `devShell`** — `nix develop` returns a bare shell. A dev shell with `nixfmt`, `statix`, `deadnix`, `sops` is desirable.
- **No package tests** — `passthru.tests` not defined on any package.
- **No `checks`** — `checks.x86_64-linux` evaluates to an empty list (only deploy-rs checks wired).
