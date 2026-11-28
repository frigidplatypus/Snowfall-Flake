{
  autoPatchelfHook,
  common-updater-scripts,
  fetchzip,
  lib,
  nixosTests,
  stdenv,
  stdenvNoCC,
  writeShellScript,
}:
# 3.0.0 splits releases: silverbullet-server-*.zip carries the server binary,
# sb-*.zip the CLI client. Both installed (module runs bin/silverbullet).
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "silverbullet";
  version = "3.0.1";

  src =
    finalAttrs.passthru.sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  cliSrc =
    finalAttrs.passthru.cliSources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src/silverbullet $out/bin/silverbullet
    cp $cliSrc/sb $out/bin/sb
    chmod +x $out/bin/silverbullet $out/bin/sb
    runHook postInstall
  '';

  passthru = {
    sources = {
      "x86_64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/silverbullet-server-linux-x86_64.zip";
        hash = "sha256-xoDcTfbBKP1OevKn2k+w/19Luf/biya2fDz87Dwygiw=";
        stripRoot = false;
      };
      "aarch64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/silverbullet-server-linux-aarch64.zip";
        hash = "sha256-dO+DOfdYocltr2vLnp1V/ovlWaEHKnS0qYq9u+FScnA=";
        stripRoot = false;
      };
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/silverbullet-server-darwin-aarch64.zip";
        hash = "sha256-RzmhHBfq3xCl2I7wsvP/gYphsj55P4OwWzIrq1iK4IA=";
        stripRoot = false;
      };
    };

    cliSources = {
      "x86_64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-linux-x86_64.zip";
        hash = "sha256-m7SASbymlcEKan+Mcm0/KrW0JM9episbc6cotAiThaw=";
        stripRoot = false;
      };
      "aarch64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-linux-aarch64.zip";
        hash = "sha256-wCgLPnXnUvLYwvpaBJ6ukVfwkdZuqWSQ5UAibU8mv0s=";
        stripRoot = false;
      };
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-darwin-aarch64.zip";
        hash = "sha256-uu9CtOuXso1ZZGEVUVMuQgU74+I6YNfCpIm9KZ9Bf00=";
        stripRoot = false;
      };
    };

    updateScript = writeShellScript "update-silverbullet" ''
      NEW_VERSION="$1"
      for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
        ${lib.getExe' common-updater-scripts "update-source-version"} "silverbullet" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';

    tests = {
      inherit (nixosTests) silverbullet;
    };
  };

  meta = {
    changelog = "https://github.com/silverbulletmd/silverbullet/blob/${finalAttrs.version}/website/CHANGELOG.md";
    description = "Open-source, self-hosted, offline-capable Personal Knowledge Management (PKM) web application";
    homepage = "https://silverbullet.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aorith ];
    mainProgram = "silverbullet";
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
