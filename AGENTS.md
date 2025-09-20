# AGENTS.md - Snowfall NixOS Flake

## Build/Test Commands
- `nix flake check` - Validate flake syntax and evaluate all outputs
- `nix build .#<package>` - Build specific package (e.g., `nix build .#cliflux`)
- `nixos-rebuild switch --flake .#<hostname>` - Deploy to NixOS system
- `home-manager switch --flake .#<user>@<hostname>` - Deploy home configuration  
- `nix develop` - Enter development shell with git, nix, neovim, tmux, fish

## Codebase Structure
This is a Snowfall Lib-based NixOS flake with modular architecture:
- `modules/nixos/` - NixOS system modules
- `modules/home/` - Home Manager modules  
- `systems/` - Host configurations
- `homes/` - User-specific home configurations
- `packages/` - Custom package derivations
- `overlays/` - Package overlays

## Code Style & Conventions
- Use `with lib; with lib.frgd;` imports pattern
- Define options with `mkOpt type default description` helper
- Use `enabled`/`disabled` shortcuts for boolean options  
- Follow let-in pattern: `let cfg = config.frgd.<module>; in`
- Namespace all options under `frgd.*` (e.g., `frgd.user.enable`)
- Use kebab-case for module names, camelCase for option names
- Add descriptive comments for complex configurations
- Use `inherit` for cleaner attribute extraction