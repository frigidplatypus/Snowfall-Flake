{
  buildNpmPackage,
  fetchFromGitHub,
  stdenv,
  lib,
  pkgs,
}:

let
  repo = fetchFromGitHub {
    name = "taskwarrior-webui";
    owner = "DCsunset";
    repo = "taskwarrior-webui";
    rev = "master";
    sha256 = "sha256-TgmPMrBlB43nFFULyH30lI/NmySmdT0E3+9ONOVyD+8=";
  };

  frontend = buildNpmPackage {
    name = "taskwarrior-webui-frontend";
    src = repo;
    sourceRoot = "${repo.name}/frontend";
    npmDepsHash = "sha256-wrEfYd8EXr5T4gV+plzBl184M8VAT0KzHtrkASjjGlA=";
    npmFlags = [ "--legacy-peer-deps" ];
    installPhase = ''
      mkdir -p $out
      cp -rv . $out/
      pushd $out; npm run build; npm run export
    '';
  };

  backend = buildNpmPackage {
    name = "taskwarrior-webui-backend";
    src = repo;
    sourceRoot = "${repo.name}/backend";
    npmDepsHash = "sha256-KJzNuIcYF/3ZmpXymaPer1luJLgsMemtJ4eqYdh+HFA=";
    npmFlags = [ "--legacy-peer-deps" ];
    installPhase = ''
      mkdir -p $out
      cp -rv . $out/
      pushd $out; npm run build
    '';
  };
in
stdenv.mkDerivation {
  name = "taskwarrior-webui";
  buildInputs = [
    frontend
    backend
    pkgs.nodejs
  ];
  src = repo;
  installPhase = ''
    mkdir -p $out/frontend/
    mkdir -p $out/backend/
    cp -r ${frontend}/* $out/frontend/
    cp -r ${backend}/* $out/backend/
  '';
  meta = {
    description = "A web UI for Taskwarrior";
    homepage = "https://github.com/DCsunset/taskwarrior-webui";
    license = lib.licenses.gpl3;
    maintainers = [ "justinmartin" ];
    platforms = lib.platforms.all;
  };
}
