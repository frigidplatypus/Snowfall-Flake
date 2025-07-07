{ pkgs, stdenv, ... }:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "cria";
  version = "0.8.5";

  buildInputs = [
    pkgs.pkg-config
    pkgs.openssl.dev
  ];
  nativeBuildInputs = [
    pkgs.pkg-config
  ];
  src = pkgs.fetchFromGitHub {
    owner = "frigidplatypus";
    repo = "cria";
    rev = "v${version}";
    sha256 = "sha256-BTK5uE1N/zF4gx+vddL1p1dBG8nUGpZ7Cy1p7gY+vu4=";
  };

  cargoHash = "sha256-j6NEmuNn50bwktONs6OcVfhKKgst0IV4SK7iBzSZK7c=";
  meta = with pkgs.lib; {
    description = "A TUI for Vikunja";
    homepage = "https://github.com/frigidplatypus/cria";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
