{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "blocky-visor";
  version = "0.0.0-unstable-2026-10-06";

  src = fetchFromGitHub {
    owner = "JCHHeilmann";
    repo = "blocky-visor";
    rev = "b966c12ff95e390a8f971e82e32ebdee662f00aa";
    hash = "sha256-+CjgM1pAgEg2Iww1COvhlemZJmBpsAXiYXQb5p03xk4=";
  };

  npmDepsHash = "sha256-+uDCaUcg+gDBspzxJRoCi0O6ct3YfN7ooXkIR5315Xs=";

  # blocky >= 0.25 expects POST for /api/cache/flush; visor sends PUT (405).
  postPatch = ''
    substituteInPlace src/lib/api/cache.ts \
      --replace-fail 'method: "PUT"' 'method: "POST"'
  '';

  installPhase = ''
    runHook preInstall
    install -d $out
    cp -r build/* $out/
    runHook postInstall
  '';

  meta = {
    description = "Static web dashboard for the blocky DNS server";
    homepage = "https://github.com/JCHHeilmann/blocky-visor";
    license = lib.licenses.mit;
  };
})
