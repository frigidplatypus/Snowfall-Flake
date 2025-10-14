# AGENTS.md - Snowfall NixOS Flake

## Build / Lint / Test
- **Check:** `nix flake check` — validate flake and all outputs
- **Build package:** `nix build .#<package>` (e.g. `nix build .#cliflux`)
- **Run a single package test:** `nix build .#<package>.tests` or `nix run .#<package>.tests` (when test output exists)
- **Deploy NixOS:** `nixos-rebuild switch --flake .#<hostname>`
- **Deploy Home Manager:** `home-manager switch --flake .#<user>@<hostname>`
- **Dev shell:** `nix develop` — opens a development environment
- **Format Nix:** `nixpkgs-fmt` or `alejandra` when configured in CI/dev shell

## Style & Conventions
- **Imports:** prefer `with lib; with lib.frgd;` at top of module files
- **Options:** define and validate with `mkOpt type default description`
- **Patterns:** use `let cfg = config.frgd.<module>; in` and `inherit` attrs for clarity
- **Naming:** kebab-case for module filenames, camelCase for option names, avoid one-letter vars
- **Formatting:** keep expressions short, wrap long lines, run `nixpkgs-fmt` before commits
- **Types & Errors:** prefer explicit option types and fail early with `throw` and clear messages
- **Testing & CI:** prefer hermetic tests via `nix build .#...tests`; run single-test builds locally
- **Comments & Reviews:** add concise comments for complex logic; keep modules pure (no side effects)
- **Cursor/Copilot:** no `.cursor` or `.github/copilot-instructions.md` detected; include any such rules here when added
