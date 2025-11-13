{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  ...
}:

let
  # NOTE: pick a release tag you want to track. Update `version` and
  # the corresponding `hash` and `vendorHash` to the correct values when
  # you evaluate this package. I used a conservative placeholder here so
  # the file can be reviewed/edited in-tree before attempting a build.
  version = "0.1.0";
in

buildGoModule {
  pname = "tclip";
  inherit version;

  src = fetchFromGitHub {
    owner = "tailscale-dev";
    repo = "tclip";
    rev = "v${version}";
    # Replace the sha256 below with the real hash for the chosen rev.
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # If upstream vendors modules, set vendorHash; otherwise remove.
  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  meta = with lib; {
    description = "tclip - paste service (CLI/daemon)";
    homepage = "https://github.com/tailscale-dev/tclip";
    license = licenses.mit;
    maintainers = with maintainers; [];
  };
}
