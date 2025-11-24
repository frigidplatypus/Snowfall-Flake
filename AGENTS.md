# AGENTS.md - Snowfall NixOS Flake

## Build / Lint / Test
- `nix flake check` — validate flake and all outputs
- `nix build .#<package>` — build a single package (e.g. `nix build .#cliflux`)
- `nix build .#<package>.tests` or `nix run .#<package>.tests` — run a single package test
- `nix develop` — open dev shell with project tools
- `nixpkgs-fmt` or `alejandra` — format Nix code (run before commits)
- `nixos-rebuild switch --flake .#<hostname>` — deploy NixOS
- `home-manager switch --flake .#<user>@<hostname>` — deploy Home Manager

## Code Style & Conventions
- Imports: prefer `with lib; with lib.frgd;` at the top of module files for readable scope
- Options: declare with explicit types using `mkOpt type default description`; validate early
- Naming: module filenames use kebab-case, option names use camelCase; avoid one-letter vars
- Structure: use `let cfg = config.frgd.<module>; in` and `inherit` for clarity and minimal duplication
- Formatting: keep expressions short, wrap long lines, run `nixpkgs-fmt`; prefer small, pure modules
- Types & errors: prefer explicit types for options; `throw` early with clear messages on invalid input
- Testing: prefer hermetic tests via `nix build .#...tests`; run single-package tests locally
- Comments: add concise comments for non-obvious logic; avoid noisy comments

## Tooling Notes
- If `.cursor/rules/` or `.cursorrules` exist, include those rules here for agent guidance
- If `.github/copilot-instructions.md` exists, copy any repo-specific Copilot rules into this file

Keep this file short and pragmatic — it guides automated agents operating in this repo.