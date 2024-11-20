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

  api = buildNpmPackage {
    name = "taskwarrior-api";
    src = repo;
    sourceRoot = "${repo.name}/backend";
    npmDepsHash = "sha256-KJzNuIcYF/3ZmpXymaPer1luJLgsMemtJ4eqYdh+HFA=";
    npmFlags = [ "--legacy-peer-deps" ];
    buildInputs = [ pkgs.nodejs ];
    installPhase = ''
      mkdir -p $out
      cp -rv . $out/
      pushd $out
      DIR=$out
      npm run build
      sed -i 's/localhost/100.100.7.29/g' dist/app.js
      sed -i 's/3000/3001/g' dist/app.js
      sed -i 's|"start": "node ./dist/app.js"|"start": "${pkgs.nodejs}/bin/node $out/dist/app.js"|' package.json
      sed -i "s|\$out|$DIR|g" package.json
    '';
  };
  startBackendScript = pkgs.writeShellScriptBin "start-backend-server" ''
    ${pkgs.nodejs}/bin/npm start --prefix ${api}
  '';

in
stdenv.mkDerivation {
  name = "taskwarrior-api";
  buildInputs = [
    api
    startBackendScript
    pkgs.taskwarrior3
  ];
  src = repo;
  installPhase = ''
    mkdir -p $out/server/
    cp -r ${api}/* $out/server/
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
