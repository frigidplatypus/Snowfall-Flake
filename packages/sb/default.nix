{
  autoPatchelfHook,
  common-updater-scripts,
  fetchzip,
  lib,
  stdenv,
  stdenvNoCC,
  writeShellScript,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sb";
  version = "2.8.1";

  src =
    finalAttrs.passthru.sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $src/sb $out/bin/
    runHook postInstall
  '';

  passthru = {
    sources = {
      "x86_64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-linux-x86_64.zip";
        hash = "sha256-DdMtn0RE0pioTGj2e59ioGQihotL6WNGHb3vRnrG1TI=";
        stripRoot = false;
      };
      "aarch64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-linux-aarch64.zip";
        hash = "sha256-8+MpL8Ob2VQDwjIrOcjWCIjEnsZAW5Zj5bfZSVjAl2k=";
        stripRoot = false;
      };
      "x86_64-darwin" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-darwin-x86_64.zip";
        hash = "sha256-c9PrV144B23UaAI2vWJfn6yF+MpY4j9NrssCr81yOy0=";
        stripRoot = false;
      };
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-darwin-aarch64.zip";
        hash = "sha256-QO2yQoOhWZrXN+QVwi6MR6oKVK9V4BXiqIMW2qPJqu8=";
        stripRoot = false;
      };
    };

    updateScript = writeShellScript "update-sb" ''
      NEW_VERSION="$1"
      for platform in ${lib.escapeShellArgs finalAttrs.meta.platforms}; do
        ${lib.getExe' common-updater-scripts "update-source-version"} "sb" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    changelog = "https://github.com/silverbulletmd/silverbullet/blob/${finalAttrs.version}/website/CHANGELOG.md";
    description = "CLI client for SilverBullet";
    homepage = "https://silverbullet.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aorith ];
    mainProgram = "sb";
    platforms = builtins.attrNames finalAttrs.passthru.sources;
  };
})
