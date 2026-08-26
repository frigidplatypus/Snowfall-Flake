{
  autoPatchelfHook,
  fetchzip,
  lib,
  stdenv,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "outl";
  version = "0.12.0-beta.168";

  src =
    finalAttrs.passthru.sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.lib ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src/outl $out/bin/
    runHook postInstall
  '';

  passthru = {
    sources = {
      "x86_64-linux" = fetchzip {
        url = "https://github.com/outlmd/outl/releases/download/v${finalAttrs.version}/outl-linux-x64.tar.gz";
        hash = "sha256-ZUHfqkOaBHQ7jfIY+HqD6wP+TX6oR9xGbsvLoEfaymM=";
        stripRoot = false;
      };
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/outlmd/outl/releases/download/v${finalAttrs.version}/outl-macos-arm64.tar.gz";
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        stripRoot = false;
      };
      "x86_64-darwin" = fetchzip {
        url = "https://github.com/outlmd/outl/releases/download/v${finalAttrs.version}/outl-macos-x64.tar.gz";
        hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        stripRoot = false;
      };
    };
  };

  meta = {
    description = "Local-first outliner with CRDT sync. Markdown is the source of truth";
    homepage = "https://outl.app";
    license = lib.licenses.mit;
    mainProgram = "outl";
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
