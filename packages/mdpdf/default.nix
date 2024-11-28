{
  buildNpmPackage,
  fetchFromGitHub,
  pkgs,
}:

let
  repo = fetchFromGitHub {
    name = "mdpdfRepo";
    owner = "elliotblackburn";
    repo = "mdpdf";
    rev = "3.0.2";
    sha256 = "sha256-u38hzZwWeNUrOFkmv+BflEOj2mgrg+Pt64QeV5ql78Y=";
  };

in
buildNpmPackage {
  name = "mdpdf";
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
  postInstall = ''
    wrapProgram $out/bin/mdpdf \
    --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromium.outPath}/bin/chromium
  '';
}
