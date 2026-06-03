# ❄️ Frigid Platypus — NixOS Homelab Flake

[![Built with Snowfall Lib](https://img.shields.io/badge/Snowfall%20Lib-powered-blue)](https://snowfall.org/lib)

Personal NixOS infrastructure flake managing **Justin Martin's homelab** — 24 NixOS hosts, 14 Home Manager configs, and a growing collection of services running across Proxmox LXC containers, bare-metal machines, and VPS instances.

Built on [Snowfall Lib](https://github.com/snowfallorg/lib) for automatic module/package/host discovery, inspired by [Jake Hamilton's config](https://github.com/jakehamilton/config).

---

## Quick Start

```bash
# Deploy a host
nixos-rebuild switch --flake .#<hostname>

# Deploy Home Manager
home-manager switch --flake .#<user>@<hostname>

# Deploy via deploy-rs (skip p5810, t480)
nix run github:serokell/deploy-rs -- --flake .#<hostname>

# Build a single package
nix build .#<package>

# Validate the flake
nix flake check

# Format code
nixfmt
```

## Custom CLI Tools

These are defined in `modules/home/cli-apps/local-scripts/` and installed via Home Manager:

| Tool | Description |
|------|-------------|
| `nr` | Bulk deploy tool — deploy to all eligible hosts (default excludes `p5810`). Supports `--select` (interactive host picker), `--dry-run`, `--build`, `--notify` (ntfy.sh), `--strict`, health checks. Config at `~/.config/nr/nrrc`. |
| `fu` | `nix flake update` shortcut — `cd` to flake path and update inputs |
| `fe` | `nvim .` shortcut — open the flake directory in Neovim |
| `fs` | Linux: `figlet $(hostname); nh os switch` |
| `ds` | macOS: `figlet $(hostname); nh darwin switch` |

## At a Glance

| Category | Count |
|----------|-------|
| NixOS hosts | 24 |
| Home Manager configs | 14 |
| Custom packages | 10 |
| NixOS modules | ~70 |
| Home Manager modules | ~30 |
| Service modules | ~30 |
| Archetypes | 5 |
| Suites | 10 |

## Documentation

See the [`docs/`](docs/) directory:

- **[HOSTS.md](docs/HOSTS.md)** — Every host documented with purpose, services, hardware
- **[WORKFLOW.md](docs/WORKFLOW.md)** — Adding a host, adding a module, deploying, troubleshooting
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** — Module namespace, lib helpers, suite/archetype system, code conventions

## Credits

Built with [Snowfall Lib](https://github.com/snowfallorg/lib) by [Jake Hamilton](https://github.com/jakehamilton).
Much of the module structure and conventions are adapted from his [personal config](https://github.com/jakehamilton/config).
