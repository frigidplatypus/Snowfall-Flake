# Workflows

Common tasks for maintaining the flake.

---

## Adding a New Host

1. **Create host directory**
   ```bash
   mkdir -p systems/x86_64-linux/<hostname>
   ```

2. **Create default.nix**
   ```nix
   { lib, modulesPath, pkgs, config, ... }:
   with lib;
   with lib.frgd;
   {
     imports = [
       (modulesPath + "/virtualisation/proxmox-lxc.nix")  # if LXC
       # ./hardware.nix  # if bare metal
       # ./disko.nix     # if disko partitioning
     ];

     frgd = {
       nix = enabled;
       archetypes.lxc = enabled;  # or server, workstation, vm

       # Per-host services
       services.caddy-proxy = {
         enable = true;
         hosts.<hostname> = {
           hostname = "<host>.${tailnet}";
           backendAddress = "http://127.0.0.1:<port>";
           useTailnet = true;
         };
       };
     };
   }
   ```

   **Key decisions:**
   - **LXC container** → `archetypes.lxc` (most homelab services). Imports `virtualisation/proxmox-lxc.nix` and sets `boot.isContainer = true`.
   - **Bare metal server** → `archetypes.server`, includes `common-slim` suite (ssh, tailscale, beszel, sops, doas, git, direnv, comma, etc.)
   - **Bare metal workstation** → `archetypes.workstation`, includes full `desktop` + `development` suites
   - **VM (Proxmox/QEMU)** → `archetypes.vm`, includes `boot.loader` config and qemu-guest-agent

3. **Add hardware config** (bare metal only)
   ```bash
   cp systems/x86_64-linux/nixos-anywhere/hardware.nix systems/x86_64-linux/<hostname>/
   ```
   Edit to match the machine's hardware.

4. **Add disko config** (optional, for disk partitioning)
   See existing examples like `systems/x86_64-linux/echidna/disko.nix` or `systems/x86_64-linux/nasnix/disko.nix`.

5. **Verify the host is recognized**
   ```bash
   nix eval .#nixosConfigurations --apply builtins.attrNames
   ```

6. **Provision** (if new machine):
   ```bash
   nix run nixpkgs#nixos-anywhere -- --flake .#<hostname> root@<ip>
   ```

7. **Deploy**:
   ```bash
   nixos-rebuild switch --flake .#<hostname> --target-host root@<hostname>
   ```

8. **Exclude from bulk deploy** (optional): Add to `excludedHosts` in your Home Manager `local-scripts` config or `nr`'s `EXCLUDED_HOSTS`.

---

## Adding a New Module

### NixOS Module

```bash
mkdir -p modules/nixos/<category>/<module-name>
```

```nix
# modules/nixos/<category>/<module-name>/default.nix
{ lib, config, pkgs, ... }:
with lib;
with lib.frgd;
let
  cfg = config.frgd.<category>.<module-name>;
in
{
  options.frgd.<category>.<module-name> = with types; {
    enable = mkBoolOpt false "Whether to enable <module-name>.";
    # customOption = mkOpt str "default" "Description.";
  };

  config = mkIf cfg.enable {
    # ... configuration
  };
}
```

### Home Manager Module

```bash
mkdir -p modules/home/<category>/<module-name>
```

Same pattern but under `modules/home/` with Home Manager-compatible options.

### Snowfall Auto-Discovery

Snowfall Lib automatically picks up:
- `modules/nixos/<path>/default.nix` → `frgd.<path>` in the NixOS module system
- `modules/home/<path>/default.nix` → `frgd.<path>` in the Home Manager module system
- `packages/<name>/default.nix` → `packages.x86_64-linux.<name>`
- `systems/x86_64-linux/<host>/default.nix` → `nixosConfigurations.<host>`
- `homes/x86_64-linux/<user>@<host>/default.nix` → `homeConfigurations.<user>@<host>`

No manual registration needed — just create the file in the right directory.

---

## Adding/Updating a Package

```bash
mkdir -p packages/<name>
```

Create `packages/<name>/default.nix` with a standard Nix derivation:

```nix
{ lib, pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "my-package";
  version = "1.0.0";
  src = ...;
  buildPhase = ...;
  installPhase = ...;
}
```

Build it: `nix build .#<name>`

---

## Deploying Changes

### Single host (local)
```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

### Single host (remote)
```bash
nixos-rebuild switch --flake .#<hostname> --target-host root@<hostname>
# or
nix run github:serokell/deploy-rs -- --flake .#<hostname>
```

> **Note:** `deploy-rs` excludes p5810 and t480 by default (see `lib/deploy/default.nix`).

### Bulk deploy (all eligible hosts)
```bash
# Deploy to all servers (excludes p5810 by default)
nr

# Interactive mode — pick hosts to deploy
nr --select

# Build only, no deploy
nr --build

# Dry run
nr --dry-run

# Deploy with notification
nr --notify

# Deploy a single host
nr <hostname>
```

### Home Manager only
```bash
home-manager switch --flake .#<user>@<hostname>
```

### First-time install on a new machine
```bash
nix run nixpkgs#nixos-anywhere -- --flake .#<hostname> root@<ip>
```
Or use the bootstrap script: `scripts/bootstrap.sh`

---

## Working with Secrets (SOPS)

### Edit a secret
```bash
sops edit modules/nixos/security/sops/secrets.yaml
sops edit modules/home/security/sops/secrets.yaml
```

> ⚠️ **NEVER** edit SOPS-encrypted YAML files with a text editor — this breaks the MAC integrity check.

### Decrypt → edit → re-encrypt
```bash
sops -d modules/nixos/security/sops/secrets.yaml > /tmp/secrets-decrypted.yaml
# edit /tmp/secrets-decrypted.yaml
sops --encrypt --in-place /tmp/secrets-decrypted.yaml
cp /tmp/secrets-decrypted.yaml modules/nixos/security/sops/secrets.yaml
```

### Key file location
- **Linux:** `/sops/keys.txt`
- **macOS:** `~/.config/sops/age/keys.txt`

---

## Common Tasks

### Update flake inputs
```bash
fu  # shortcut: nix flake update
```

### Open flake in editor
```bash
fe  # shortcut: nvim .
```

### Validate everything
```bash
nix flake check
```

### Format code
```bash
nixfmt
```

> Formatting is configured in `treefmt.toml` at the root.

### List all hosts
```bash
nix eval .#nixosConfigurations --apply builtins.attrNames
```

### List all home-manager configs
```bash
nix eval .#homeConfigurations --apply builtins.attrNames
```

### Evaluate a specific option
```bash
nix eval --json .#nixosConfigurations.<hostname>.config.frgd.<path>
```

---

## Troubleshooting

### "nix flake show" shows "unknown" for Snowfall outputs
This is a Snowfall Lib artifact — don't trust it. Use `nix eval` instead:
```bash
nix eval --json .#nixosConfigurations --apply builtins.attrNames
```

### Build fails with "option does not exist"
Make sure the module is properly placed in `modules/nixos/` or `modules/home/`. Snowfall discovers by directory structure — a typo in the path means the module isn't loaded.

### ZFS pool not importing
Check `networking.hostId` in hardware config. From a rescue shell:
```bash
zpool import -N -R /mnt zroot
nixos-enter --root /mnt
# Inside chroot: nixos-rebuild switch --flake .#<hostname>
# Exit and: zpool export zroot
```
See `systems/x86_64-linux/echidna/README.md` for detailed notes.

### Deployment fails with "generation unchanged"
Run `nr --strict` to fail explicitly on unchanged generations, or SSH in and check:
```bash
readlink /run/current-system
```

### Secrets not decrypting
- Verify the age key exists at `/sops/keys.txt` (Linux) or `~/.config/sops/age/keys.txt` (macOS)
- Check that the host is listed in the SOPS `.secrets.yaml` file under the correct key
- Run `sops --decrypt modules/nixos/security/sops/secrets.yaml` to test

### Module not applying
If a module's `enable` option is set but config doesn't apply:
- Verify the module is gated with `config = mkIf cfg.enable { ... }`
- Check for conflicting `mkForce`/`mkDefault` priority issues
- Use `nix eval` to inspect the final value:
  ```bash
  nix eval --json .#nixosConfigurations.<hostname>.config.frgd.<category>.<name>.enable
  ```

### Container won't start
For LXC containers, ensure:
- `imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];`
- `boot.isContainer = true` (set automatically by `archetypes.lxc`)
- `networking.firewall.enable = false`
