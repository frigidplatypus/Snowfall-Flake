# shellHook companion consumed by the devshell (shells/default/default.nix).
# Tailor-managed: defines helper functions only; keep the devshell's own
# overrides last. Drop hooks/<lang>.nix files exporting shell code to extend.
{ pkgs, ... }:
''
  tailor_nixos_drivers() {
    [ "''${TAILOR_NIXOS_DRIVERS-}" != 0 ] || return 1
    [ -r /etc/os-release ] || return 1
    local line
    while IFS= read -r line; do
      case "$line" in
        ID=nixos|ID=\"nixos\"|ID=\'nixos\') return 0 ;;
      esac
    done < /etc/os-release
    return 1
  }
  tailor_prepend_path() {
    local name="$1" rest="$2:''${!1-}" part result=""
    while [ -n "$rest" ]; do
      part="''${rest%%:*}"
      if [ "$rest" = "$part" ]; then rest=""; else rest="''${rest#*:}"; fi
      [ -n "$part" ] || continue
      case ":$result:" in *":$part:"*) continue ;; esac
      result="''${result:+$result:}$part"
    done
    printf -v "$name" '%s' "$result"
    export "$name"
  }
''
+ builtins.concatStringsSep "\n" [
  (if builtins.pathExists ./hooks/go.nix then import ./hooks/go.nix { inherit pkgs; } else "")
  (if builtins.pathExists ./hooks/python.nix then import ./hooks/python.nix { inherit pkgs; } else "")
  (if builtins.pathExists ./hooks/rust.nix then import ./hooks/rust.nix { inherit pkgs; } else "")
]
