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
  version = "3.0.0";

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
        hash = "sha256-/nQi3fp9SuL6o660964VSmWIkM1eMNqSan1tnA8BVEQ=";
        stripRoot = false;
      };
      "aarch64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/silverbullet-server-linux-aarch64.zip";
        hash = "sha256-RMwE8UqHKBMTST+py8aOg2GR5Z/xZn1PoBpj2uFZlZc=";
        stripRoot = false;
      };
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/silverbullet-server-darwin-aarch64.zip";
        hash = "sha256-u8eFQTkjWyPudpBr2wertdC6+ndEGt0PRkq3AHKWo/Y=";
        stripRoot = false;
      };
    };

    cliSources = {
      "x86_64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-linux-x86_64.zip";
        hash = "sha256-igIREgKgug6W6u9xUUND83mDQtHB4A/V61vP9/CNqUk=";
        stripRoot = false;
      };
      "aarch64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-linux-aarch64.zip";
        hash = "sha256-MHmuWu+FbYYDaG5k0hsiNYfvJEw70HXLYhzIdCEjFC4=";
        stripRoot = false;
      };
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-darwin-aarch64.zip";
        hash = "sha256-3dmCoWgcNxuIwQmrUdVwsz8josE/dXsj6vox+zfghq8=";
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
