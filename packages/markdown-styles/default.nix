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
    rev = "3.2.0";
    sha256 = "sha256-u38hzZwWeNUrOFkmv+BflEOj2mgrg+Pt64QeV5ql78Y=";
  };

in
buildNpmPackage {
  name = "markdwon-styles";
  src = repo;
  npmDepsHash = "sha256-VPiTn/bbx0bbLWTNdxD+krVtHlI8V6TrdrW1jS7OIxE=";
  npmFlags = [ "--legacy-peer-deps" ];
  PUPPETEER_SKIP_DOWNLOAD = true;
  dontNpmBuild = true;
  buildInputs = [ pkgs.nodejs ];
  nativeBuildInputs = [ pkgs.buildPackages.makeWrapper ];
  prePatch = ''
    export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
    export PUPPETEER_SKIP_DOWNLOAD=1
  '';
  # postInstall = ''
  #   wrapProgram $out/bin/mdpdf \
  #   --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium.outPath}/bin/chromium
  # '';
}
