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
  version = "0.23.2";
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
    sha256 = "sha256-r39Mm2b1I3sL0r9pBnAGu6UKCcjVOZp+W5gHeV3vkuE=";
  };

  # vendorHash for go modules (computed from an earlier build attempt).
  vendorHash = "sha256-QP0POCKRc0IFqjod1iRUKIqnBVk5wTe/wpceiJT98gQ=";

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
