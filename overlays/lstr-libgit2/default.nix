{ ... }:

final: prev:

{
  # lstr 0.4.0 vendors libgit2-sys, but the nixpkgs cargo build hook exports
  # LIBGIT2_NO_VENDOR=1, so the build must link the system library. The
  # upstream expression only ships openssl.dev in buildInputs, so the
  # pkg-config probe panics ("no compatible system libgit2 could be found").
  # Drop once nixpkgs' lstr expression gains libgit2 (or the vendoring flag).
  lstr = prev.lstr.overrideAttrs (
    finalAttrs: prevAttrs: {
      buildInputs = (prevAttrs.buildInputs or [ ]) ++ [ prev.libgit2 ];
    }
  );
}
