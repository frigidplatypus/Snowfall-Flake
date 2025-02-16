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
    rev = "v1.5.0";
    sha256 = "sha256-plfJnKdKsPH2VCexOpO0jduF5cXD4cGHi+eviuueaMY=";
  };
in

pkgs.rustPlatform.buildRustPackage {
  pname = "cliflux";
  version = "v1.5.0";
  src = repo;
  cargoHash = "sha256-tTLsd/KavSpGXyGRbpVGQiY7tnDfkGz5N/9zni2fvJA=";
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    useFetchCargoVendor = true;
  OPENSSL_NO_VENDOR = 1;
  nativeBuildInputs = with pkgs; [
    pkg-config
    openssl
    openssl.dev
  ];
}
