{ channels, ... }:
final: prev:

{
  # Backport of NixOS/nixpkgs#568618 (merged 2026-09-30, after our pinned
  # nixpkgs rev). Vendored libghostty-vt bundles compiler-rt/ubsan objects
  # whose FDEs ld.bfd 2.46 rejects: ".eh_frame_hdr refers to overlapping
  # FDEs". Disabling bundling fixes the herdr link.
  herdr = prev.herdr.overrideAttrs (
    finalAttrs: prevAttrs: {
      postPatch =
        (prevAttrs.postPatch or "")
        + final.lib.optionalString final.stdenv.hostPlatform.isLinux ''
          substituteInPlace vendor/libghostty-vt/src/build/GhosttyLibVt.zig \
            --replace-fail 'lib.bundle_compiler_rt = true;' 'lib.bundle_compiler_rt = false;' \
            --replace-fail 'lib.bundle_ubsan_rt = true;' 'lib.bundle_ubsan_rt = false;'
        '';
    }
  );
}
