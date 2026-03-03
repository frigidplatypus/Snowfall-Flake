# AGENTS.md - Frigid Platypus NixOS Flake

This flake is built with [Snowfall Lib](https://snowfall.org/), which defines the structure and auto-imports all modules. All options live under the `frgd` namespace.

## Build / Lint / Test

```bash
# Validate entire flake
nix flake check

# Build a single package
nix build .#cliflux
nix build .#matcha

# Run package tests
nix build .#cliflux.tests
nix run .#cliflux.tests

# Open dev shell with project tools
nix develop

# Format Nix code (run before commits)
nixpkgs-fmt .
# or
alejandra .

# Deploy NixOS
sudo nixos-rebuild switch --flake .#<hostname>

# Deploy Home Manager
home-manager switch --flake .#<user>@<hostname>

# Example hosts: t480, echidna, p5810, books, klipper, etc.
```

## Snowfall-Lib Structure

This flake follows Snowfall-Lib's opinionated directory structure. Modules are auto-imported - no manual imports needed in flake.nix.

```
flake/
├── flake.nix           # Entry point, uses lib.mkFlake
├── modules/
│   ├── nixos/         # NixOS modules (imported automatically)
│   ├── home/          # Home Manager modules
│   └── darwin/        # Darwin modules
├── packages/          # Package derivations
├── systems/           # System configurations (x86_64-linux/t480, etc.)
├── homes/             # Home Manager configurations
└── lib/               # Custom library functions (optional)
```

### Namespace
- All options use the `frgd` namespace (defined in flake.nix)
- Example: `frgd.cli-apps.matcha`, `frgd.security.keyring`, `frgd.suites.common`

### Auto-Import Behavior
Snowfall-Lib automatically imports all modules from:
- `modules/nixos/*/default.nix` → available as `frgd.nixos.*`
- `modules/home/*/default.nix` → available as `frgd.home.*`
- `modules/darwin/*/default.nix` → available as `frgd.darwin.*`

## Code Style & Conventions

### Imports
Always use these at the top of module files:
```nix
with lib;
with lib.frgd;
```

### NixOS Module Pattern
```nix
{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.<module>.<name>;
in
{
  options.frgd.<module>.<name> = with types; {
    enable = mkBoolOpt false "Description.";
    # Other options...
  };

  config = mkIf cfg.enable {
    # Configuration...
  };
}
```

### Home Manager Module Pattern
```nix
{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.<module>.<name>;
  configFile = pkgs.formats.json { }.generate "config.json" cfg.settings;
in
{
  options.frgd.<module>.<name> = with types; {
    enable = mkBoolOpt false "Description.";
    package = mkOpt types.package pkgs.somepackage "Package to use.";
    settings = mkOpt (attrsOf anything) { } "Configuration settings.";
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."app/config.json".source = configFile;
  };
}
```

### Option Types
- Use `mkBoolOpt` for booleans: `mkBoolOpt false "Whether to enable foo."`
- Use `mkOpt type default description` for other options
- Common types: `types.package`, `types.str`, `types.int`, `types.bool`, `types.listOf types.str`, `types.attrsOf anything`

### Naming Conventions
- Module filenames: kebab-case (e.g., `gnome-keyring`, `tmux`)
- Option names: camelCase (e.g., `enable`, `package`, `settings`)
- Variable names: avoid one-letter vars, use descriptive names
- Config variable: `let cfg = config.frgd.<module>.<name>; in`

### Structure
- Keep expressions short and wrap long lines
- Prefer small, pure modules with single responsibilities
- Use `inherit` to reduce duplication
- Use `mkIf cfg.enable` to conditionally enable configuration

### Error Handling
- Use `throw` early with clear error messages for invalid configuration
- Validate options early in the module

### Secret Handling
This flake uses sops-nix for secrets:
- Secrets stored in `modules/nixos/security/sops/secrets.yaml`
- Access via `config.sops.secrets.<secret-name>.path`
- Example: `passwordCommand = "cat ${config.sops.secrets.my_password.path}";`

### Configuration File Generation
- Use `pkgs.formats.json { }.generate "filename" data` for JSON
- Use `xdg.configFile."app/subdir/file".source = ./file;` for static files
- Use `xdg.configFile."app/file".text = ''content'';` for inline text

## Creating New Modules

### Where to Place Modules
- NixOS system-level config: `modules/nixos/<category>/<name>/`
- User-level config (Home Manager): `modules/home/<category>/<name>/`
- Categories: `cli-apps`, `apps`, `services`, `security`, `tools`, `desktop`, etc.

### Creating a NixOS Module
```bash
mkdir -p modules/nixos/cli-apps/matcha
```
```nix
# modules/nixos/cli-apps/matcha/default.nix
{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.matcha;
in
{
  options.frgd.cli-apps.matcha = with types; {
    enable = mkBoolOpt false "Whether to enable Matcha.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.matcha ];
  };
}
```

### Creating a Home Manager Module
```bash
mkdir -p modules/home/cli-apps/matcha
```
```nix
# modules/home/cli-apps/matcha/default.nix
{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.matcha;
in
{
  options.frgd.cli-apps.matcha = with types; {
    enable = mkBoolOpt false "Whether to enable Matcha.";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.matcha ];
  };
}
```

### Enabling a Module in a System
In `systems/x86_64-linux/<host>/default.nix`:
```nix
frgd.cli-apps.matcha.enable = true;
```

### Enabling a Module in Home Manager
In `homes/x86_64-linux/<user>@<host>/default.nix`:
```nix
frgd.cli-apps.matcha.enable = true;
```

## Testing

Run these commands to validate changes:
```bash
# Check entire flake for errors
nix flake check

# Build a specific package to verify derivation
nix build .#matcha

# Format code before committing
nixpkgs-fmt .
```

## Package Development

To add a new package:
1. Create `packages/<name>/default.nix` with a standard derivation
2. The package is auto-exposed via the overlay in flake.nix
3. Access via `pkgs.frgd.<name>` or `pkgs.<name>`

Example package structure:
```nix
{ lib, fetchFromGitHub, buildGoModule, ... }:

buildGoModule {
  pname = "my-package";
  version = "1.0.0";
  src = fetchFromGitHub { ... };
  vendorHash = "sha256-...";
}
```

## Tooling Notes

If `.cursor/rules/` or `.cursorrules` exist, include those rules here for agent guidance.
If `.github/copilot-instructions.md` exists, copy any repo-specific Copilot rules into this file.

---

Keep this file pragmatic and focused. It guides automated agents operating in this repo.
