#!/bin/sh

set -eu

host="surface"
cache_name="frgd-surface-kernel"
push_results=1

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

Options:
  --host HOST    NixOS host to build (default: surface)
  --cache NAME   Cachix cache name to push to (default: frgd-surface-kernel)
  --no-push      Build only; do not push to Cachix
  -h, --help     Show this help text
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

kernel_attr=".#nixosConfigurations.${host}.config.system.build.kernel"
initrd_attr=".#nixosConfigurations.${host}.config.system.build.initialRamdisk"
version_attr=".#nixosConfigurations.${host}.config.boot.kernelPackages.kernel.version"

kernel_version=$(nix eval --raw "$version_attr")

printf 'Building kernel %s for host %s\n' "$kernel_version" "$host"
nix build --out-link "$kernel_link" "$kernel_attr"

printf 'Building initial ramdisk for host %s\n' "$host"
nix build --out-link "$initrd_link" "$initrd_attr"

printf 'Kernel result: %s\n' "$kernel_link"
printf 'Initrd result: %s\n' "$initrd_link"

if [ "$push_results" -eq 1 ]; then
    printf 'Pushing results to Cachix cache %s\n' "$cache_name"
    nix run nixpkgs#cachix -- push "$cache_name" "$kernel_link" "$initrd_link"
fi
