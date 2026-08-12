#!/bin/sh

set -eu

host="surface"
cache_name="frgd-surface-kernel"
push_results=1
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
cachix_config="$config_home/cachix/cachix.dhall"
cachix_env_file="${SURFACE_KERNEL_CACHE_ENV_FILE:-/run/secrets/rendered/surface-kernel-cache.env}"

if [ -r "$cachix_env_file" ]; then
    # Load the same Cachix token file used by the systemd service.
    set -a
    . "$cachix_env_file"
    set +a
fi

has_cachix_credentials() {
    [ -n "${CACHIX_AUTH_TOKEN:-}" ] || [ -n "${CACHIX_SIGNING_KEY:-}" ] || [ -f "$cachix_config" ]
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --host)
            host="$2"
            shift 2
            ;;
        --cache)
            cache_name="$2"
            shift 2
            ;;
        --no-push)
            push_results=0
            shift
            ;;
        -h|--help)
            cat <<'EOF'
Usage: scripts/build_surface_kernel_cache.sh [options]

Build the configured kernel and initial ramdisk for a host and optionally
push both results to Cachix.

The script updates flake inputs in the repository root before building.

Options:
  --host HOST    NixOS host to build (default: surface)
  --cache NAME   Cachix cache name to push to (default: frgd-surface-kernel)
  --no-push      Build only; do not push to Cachix
  -h, --help     Show this help text

The Cachix push step is skipped automatically when no local Cachix
credentials are configured.
EOF
            exit 0
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            exit 1
            ;;
    esac
done

if ! command -v nix >/dev/null 2>&1; then
    echo "nix is required" >&2
    exit 1
fi

repo_root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
kernel_link="$repo_root/result-${host}-kernel"
initrd_link="$repo_root/result-${host}-initrd"

kernel_attr="$repo_root#nixosConfigurations.${host}.config.system.build.kernel"
initrd_attr="$repo_root#nixosConfigurations.${host}.config.system.build.initialRamdisk"
version_attr="$repo_root#nixosConfigurations.${host}.config.boot.kernelPackages.kernel.version"

printf 'Updating flake inputs in %s\n' "$repo_root"
nix flake update --flake "$repo_root"

kernel_version=$(nix eval --raw "$version_attr")

printf 'Building kernel %s for host %s\n' "$kernel_version" "$host"
nix build --out-link "$kernel_link" "$kernel_attr"

printf 'Building initial ramdisk for host %s\n' "$host"
nix build --out-link "$initrd_link" "$initrd_attr"

printf 'Kernel result: %s\n' "$kernel_link"
printf 'Initrd result: %s\n' "$initrd_link"

if [ "$push_results" -eq 1 ]; then
    if has_cachix_credentials; then
        printf 'Pushing results to Cachix cache %s\n' "$cache_name"
        nix run nixpkgs#cachix -- push "$cache_name" "$kernel_link" "$initrd_link"
    else
        printf 'Skipping Cachix push for %s: no credentials found in CACHIX_AUTH_TOKEN, CACHIX_SIGNING_KEY, or %s\n' "$cache_name" "$cachix_config" >&2
    fi
fi
