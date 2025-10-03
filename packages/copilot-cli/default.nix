{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  nodejs,
}:

stdenv.mkDerivation rec {
  pname = "copilot-cli";
  version = "0.0.333";

  src = fetchurl {
    url = "https://registry.npmjs.org/@github/copilot/-/copilot-${version}.tgz";
    hash = "sha256-yoUn3zA4B1+cQZsMZr67QRl27g35IWEcopihjLRy9M4=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/@github/copilot
    cp -r . $out/lib/node_modules/@github/copilot

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/copilot \
      --add-flags "$out/lib/node_modules/@github/copilot/index.js"

    runHook postInstall
  '';

  dontNpmBuild = true;

  meta = with lib; {
    description = "GitHub Copilot CLI - An AI-powered coding assistant";
    homepage = "https://github.com/github/copilot-cli";
    license = licenses.mit;
    mainProgram = "copilot";
    platforms = platforms.unix;
  };
}
