{
  pkgs,
  lib,
  fetchFromGitHub,
  ...
}:

let
  src = fetchFromGitHub {
    name = "unifly";
    owner = "hyperb1iss";
    repo = "unifly";
    rev = "v0.9.0";
    sha256 = "sha256-ZFVqEA/Ft+vYtNvvbR0MPdVVNM/W88169zU5CqZcBXY=";
  };
in

pkgs.rustPlatform.buildRustPackage {
  pname = "unifly";
  version = "v0.9.0";
  src = src;
  cargoHash = "sha256-j/poN2AdCeSNymYUAWxpy0MMqF5ZF5LTKrP1016oc94=";
  dontTest = true;
  checkPhase = "true";
  nativeBuildInputs = with pkgs; [
    pkg-config
    openssl
    openssl.dev
    lld
    makeWrapper
  ];
  buildInputs = with pkgs; [
    dbus.dev
    libclang
  ];
  postFixup = ''
    wrapProgram "$out/bin/unifly" --set LD_LIBRARY_PATH "${pkgs.dbus.lib}/lib"
  '';
}
