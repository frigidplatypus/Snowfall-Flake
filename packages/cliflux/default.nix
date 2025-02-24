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
    sha256 = "sha256-CEsbMZdv84ytVjB/oUnQTfOCsF1PnmJJRL3av/J+9bg=";
  };
in

pkgs.rustPlatform.buildRustPackage {
  pname = "cliflux";
  version = "v1.5.0";
  src = repo;
  cargoHash = "sha256-CRPBBwuAM/1A/T+ENlDvjhWlztBXeiIlRoGoLMs18io=";
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    useFetchCargoVendor = true;
  OPENSSL_NO_VENDOR = 1;
  nativeBuildInputs = with pkgs; [
    pkg-config
    openssl
    openssl.dev
  ];
}
