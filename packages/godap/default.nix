{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:

let
  version = "2.10.1";
in
buildGoModule {
  pname = "godap";
  inherit version;

  src = fetchFromGitHub {
    owner = "Macmod";
    repo = "godap";
    rev = "v${version}";
    hash = "sha256-54gKU4orzSL8RfbuxidXArxz25tc1XiKeQImpC2LkK4=";
  };

  vendorHash = "sha256-NiNhKbf5bU1SQXFTZCp8/yNPc89ss8go6M2867ziqq4=";

  meta = with lib; {
    homepage = "https://github.com/Macmod/godap";
    description = "A complete TUI for LDAP";
    license = licenses.mit;
    # maintainers = with maintainers; [ ironicbadger ];
  };
}
