{ ... }:

final: prev:

{
  # omp 18.16.0 vendors crates (zstd-sys, onig_sys, wayland-sys, drm-sys,
  # khronos-egl) that probe system libraries via pkg-config, but the cargo
  # hook exports *_NO_VENDOR and the nixpkgs expression's buildInputs only
  # cover a subset. Complete the list. Drop once nixpkgs' omp expression
  # ships these or the vendored crates go build-from-source.
  omp = prev.omp.overrideAttrs (
    finalAttrs: prevAttrs: {
      buildInputs = (prevAttrs.buildInputs or [ ]) ++ [
        final.zstd
        final.oniguruma
        final.wayland
        final.libdrm
        final.khronos
      ];
    }
  );
}
