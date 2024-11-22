{
  pkgs,
  lib,
  fetchFromGitHub,
  ...
}:
let

  repo = fetchFromGitHub {
    name = "cliflux";
    owner = "spencerwi";
    repo = "cliflux";
    rev = "v1.4.4";
    sha256 = "sha256-plfJnKdKsPH2VCexOpO0jduF5cXD4cGHi+eviuueaMY=";
  };
in

pkgs.rustPlatform.buildRustPackage {
  pname = "cliflux";
  version = "v1.4.4";
  src = repo;
  cargoHash = "sha256-TtK1hN1RNusVWxWVTity+N1cpfauhfeQpkqAOI1fIco=";
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  OPENSSL_NO_VENDOR = 1;
  nativeBuildInputs = with pkgs; [
    pkg-config
    openssl
    openssl.dev
  ];
}
