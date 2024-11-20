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
    buildPhase = ''
      runHook preBuild

      echo "Building frontend..."
      npm run build
      touch "export-should-have-finished"
      export NUXT_TELEMETRY_DISABLED=1
      npm run export

      runHook postBuild
    '';
    installPhase = ''
      mkdir -p "$out"
      cp -rv . "$out/"
      # cp -rv "$out/dist/*" "$out/static"
    '';
  };

  backend = buildNpmPackage {
    name = "taskwarrior-webui-backend";
    src = repo;
    sourceRoot = "${repo.name}/backend";
    npmDepsHash = "sha256-KJzNuIcYF/3ZmpXymaPer1luJLgsMemtJ4eqYdh+HFA=";
    npmFlags = [ "--legacy-peer-deps" ];
    buildInputs = [ pkgs.nodejs ];
    installPhase = ''
      mkdir -p $out
      cp -rv . $out/
      pushd $out

      npm run build
      sed -i 's/localhost/127.0.0.1/g' dist/app.js
    '';
  };
  startBackendScript = pkgs.writeShellScriptBin "start-backend-server" ''
    ${pkgs.nodejs}/bin/npm start --prefix ${backend}
  '';

in
stdenv.mkDerivation {
  name = "taskwarrior-webui";
  buildInputs = [
    # frontend
    backend
    startBackendScript
    pkgs.nodejs
  ];
  src = repo;
  installPhase = ''
    mkdir -p $out/backend/
    cp -r ${backend}/* $out/backend/
    cp -r ${startBackendScript}/. $out/
  '';
  meta = {
    description = "A web UI for Taskwarrior";
    homepage = "https://github.com/DCsunset/taskwarrior-webui";
    license = lib.licenses.gpl3;
    maintainers = [ "justinmartin" ];
    platforms = lib.platforms.all;
  };
}
