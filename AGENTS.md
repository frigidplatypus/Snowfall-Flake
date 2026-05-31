# AGENTS.md — Snowfall NixOS Flake

## Directory Layout (Snowfall Lib)

```
systems/<system>/<host>/       — NixOS / darwin / ISO host configs
homes/<system>/<user>@<host>/  — Home Manager configs per user+host
modules/nixos/                 — NixOS module tree (apps, services, hardware, etc.)
modules/home/                  — Home Manager module tree
modules/snowfall/              — Snowfall metadata module
packages/<name>/               — Custom package derivations
overlays/<name>/               — Package overlays
lib/                           — Library helpers (see below)
assets/                        — Static assets (wallpaper, etc.)
scripts/                       — Bootstrap / utility scripts
```

## Build / Lint / Deploy

- `nix flake check` — validate flake and all outputs (deploy-rs checks are wired)
- `nix build .#<package>` — build a single package (e.g. `nix build .#silverbullet`)
- `nix develop` — open a dev shell (currently **none defined** — gives a bare bash shell)
- `nixfmt` — format Nix code (run before commits; configured in `treefmt.toml`)
- `nixos-rebuild switch --flake .#<hostname>` — deploy NixOS (24 hosts)
- `home-manager switch --flake .#<user>@<hostname>` — deploy Home Manager (15 configs)
- `nix run github:serokell/deploy-rs -- --flake .#<hostname>` — deploy via deploy-rs (excludes p5810, t480)

**No test infrastructure exists yet.** The package tree has no `passthru.tests` and there are no per-package test files. The `checks` output is currently empty — only `deploy-rs` checks are wired but produce no results.

## Code Style & Conventions

- **Imports:** `with lib; with lib.frgd;` at the top of every module for readable scope.
- **Options block:** `options.frgd.<category>.<name> = with types; { enable = mkBoolOpt false "..."; ... }`
  - Use `mkOpt type default description` for non-bool options.
  - `mkBoolOpt` is the curried form (`mkOpt types.bool`), preferred for boolean toggles.
  - `with types;` inside the options block brings `str`, `bool`, `listOf`, etc. into scope.
- **Shorthands** (from `lib/module/default.nix`):
  - `enabled` → `{ enable = true; }`
  - `disabled` → `{ enable = false; }`
  - `font`, `tailnet` — other common value shorthands
- **Config gating:** `config = mkIf cfg.enable { ... }` — the `enable` bool is the master switch.
- **Naming:** module directory names are kebab-case; option names are camelCase.
- **Structure:** `let cfg = config.frgd.<module>; in` with `inherit` for clarity and minimal duplication.
- **Conditional config:** Use `mkMerge [ (mkIf cond1 { ... }) (mkIf cond2 { ... }) ]`, never `mkIf ... // mkIf ...`.
- **Formatting:** keep expressions short, wrap long lines, run `nixfmt`.
- **Types & errors:** prefer explicit option types; `throw` early on invalid input.
- **Comments:** add concise comments for non-obvious logic; avoid noisy ones.

## Lib Helpers (`lib/`)

| File | Purpose |
|---|---|
| `lib/module/default.nix` | Core: `mkOpt`, `mkOpt'`, `mkBoolOpt`, `enabled`, `disabled`, `tailnet` |
| `lib/deploy/default.nix` | `mkDeploy` — deploy-rs config generator (excludes p5810, t480) |
| `lib/nix-colors/default.nix` | Color scheme selection + `hexToRgba` helper |

## SOPS Secrets

- **NEVER** edit `modules/nixos/security/sops/secrets.yaml` or `modules/home/security/sops/secrets.yaml` manually with a text editor — they are AGE-encrypted SOPS files; direct edits break the MAC integrity check.
- To add/remove/edit secrets, use `sops edit <path>` or decrypt → edit → re-encrypt with `sops --encrypt --in-place`.
- Key file location: age key at `/sops/keys.txt` (Linux) or `~/.config/sops/age/keys.txt` (macOS).

## Snowfall + HM Debug Notes

- Do not treat `nix flake show` output of `unknown` as authoritative for Snowfall outputs.
- Verify concrete outputs with `nix eval`, for example:
  - `nix eval --json .#darwinConfigurations --apply builtins.attrNames`
  - `nix eval --json .#homeConfigurations --apply builtins.attrNames`
  - `nix eval --json .#homeConfigurations."<user>@<host>".config.<path>`
- For booleans, use `--json` (not `--raw`) to avoid coercion errors.
- In Nix modules, do not combine conditional attrsets via `mkIf ... // mkIf ...`; use `mkMerge [ (mkIf ...) (mkIf ...) ]` so conditions are preserved by the module system.

## Known Gaps (to be addressed)

- **No `devShell`** — `nix develop` returns a bare shell. A dev shell with `nixfmt`, `statix`, `deadnix`, `sops` is desirable.
- **No package tests** — `passthru.tests` not defined on any package.
- **No `checks`** — `checks.x86_64-linux` evaluates to an empty list.
