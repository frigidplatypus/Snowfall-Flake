{ channels, ... }:

# The niri flake is pinned to a commit whose Cargo.lock requires libdisplay-info < 0.4.0,
# but unstable nixpkgs has bumped to 0.4.0. Build niri against libdisplay-info_0_3.
# Remove this once niri's libdisplay-info-sys supports 0.4+.

final: prev:

{
  niri = prev.niri.overrideAttrs (oldAttrs: {
    buildInputs = (builtins.filter (pkg: pkg.pname != "libdisplay-info") oldAttrs.buildInputs) ++ [
      final.libdisplay-info_0_3
    ];
  });

  inherit (channels.stable-nixpkgs)
    kitty
    n8n
    matrix-synapse
    calibre-web
    ;
}
