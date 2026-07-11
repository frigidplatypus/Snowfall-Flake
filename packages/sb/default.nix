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
  version = "2.9.0";

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
        hash = "sha256-ppS90ml8U1bE4kir6YL8kpsMbecYyGU5c6Wl1eZYLDg=";
        stripRoot = false;
      };
      "aarch64-linux" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-linux-aarch64.zip";
        hash = "sha256-3mg84ZeihYkq74RgRjlvzuygpvqT0INvSAlhs/0RphA=";
        stripRoot = false;
      };
      "aarch64-darwin" = fetchzip {
        url = "https://github.com/silverbulletmd/silverbullet/releases/download/${finalAttrs.version}/sb-darwin-aarch64.zip";
        hash = "sha256-ULaFCEZ+bsK/vNnzCXfwl3c9vUeZYL1gfOU0UQqMDcs=";
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
