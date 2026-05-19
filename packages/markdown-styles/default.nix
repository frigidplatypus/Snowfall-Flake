{
  buildNpmPackage,
  fetchFromGitHub,
  pkgs,
}:
let
  repo = fetchFromGitHub {
    name = "markdown-styles-repo";
    owner = "mixu";
    repo = "markdown-styles";
    rev = "v3.2.0";
    sha256 = "sha256-OnuZoRKLThm1Pjgj8zamVN8j7McHPZ5VDaY6vOCpNV0=";
  };

in
buildNpmPackage {
  name = "markdwon-styles";
  src = repo;
  npmDepsHash = "sha256-Gcs/So7n+Mo46dwY2HfjgY9062X4xO2Zh8oe3Gw/Tfg=";
  npmFlags = [ "--legacy-peer-deps" ];
  PUPPETEER_SKIP_DOWNLOAD = true;
  dontNpmBuild = true;
  buildInputs = [ pkgs.nodejs ];
  nativeBuildInputs = [ pkgs.buildPackages.makeWrapper ];
  prePatch = ''
    export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
    export PUPPETEER_SKIP_DOWNLOAD=1
  '';
  preBuild = ''
    patchShebangs ./bin
  '';
  # postInstall = ''
  #   wrapProgram $out/bin/mdpdf \
  #   --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium.outPath}/bin/chromium
  # '';
}
