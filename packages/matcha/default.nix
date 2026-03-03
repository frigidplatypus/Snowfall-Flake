{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  go_1_26,
  ...
}:

let
  # Update `version`, `sha256` and `vendorHash` to real values before building.
  version = "0.19.1";
in

buildGoModule {
  pname = "matcha";
  inherit version;

  # matcha requires Go >= 1.26. Use go_1_26 if available in the package set.
  go = go_1_26;

  src = fetchFromGitHub {
    owner = "floatpane";
    repo = "matcha";
    rev = "v${version}";
    # Real sha256 obtained from a build attempt.
    sha256 = "sha256-oGYVYV3CxTUMKGx02xFAZaFCcfqiN6cZXYK+gUpBC3o=";
  };

  # vendorHash for go modules (computed from an earlier build attempt).
  vendorHash = "sha256-BO/f59UfZ1mjYYVpO7e3FIe1L03wrzicLF+/h/UlqUI=";

  # Ensure the build uses Go 1.26 from the provided package set.
  nativeBuildInputs = [ go_1_26 ];
  preBuild = ''
    export PATH=${go_1_26}/bin:$PATH
  '';

  meta = with lib; {
    description = "matcha - fuzzy matcher / interactive selector";
    homepage = "https://github.com/floatpane/matcha";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
