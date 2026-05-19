{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "2.11.0";
in
buildGoModule {
  pname = "godap";
  inherit version;

  src = fetchFromGitHub {
    owner = "Macmod";
    repo = "godap";
    rev = "v${version}";
    hash = "sha256-um9IsORwD4rPcqklEsRYI+J86R2vf7SE4RnTpaM6PnA=";
  };

  vendorHash = "sha256-D5Eq2JFIEmxO/FBGON+nKtGktWPOzXfv8l5akRTpz7Q=";

  meta = with lib; {
    homepage = "https://github.com/Macmod/godap";
    description = "A complete TUI for LDAP";
    license = licenses.mit;
    # maintainers = with maintainers; [ ironicbadger ];
  };
}
