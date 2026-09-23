{
  fetchurl,
  lib,
  makeWrapper,
  nodejs,
  stdenvNoCC,
}:

let
  binVersion = "1.1.7";
  binBase = "https://github.com/JuliusBrussee/caveman/releases/download/bin-v${binVersion}";

  # Native Go binaries are published per platform; only linux x86_64 is packaged here.
  goTarget =
    {
      x86_64-linux = "linux_amd64";
    }
    .${stdenvNoCC.hostPlatform.system}
      or (throw "caveman: no native binaries packaged for ${stdenvNoCC.hostPlatform.system}");

  # name -> SRI hash of the <name>_<goTarget> release asset.
  nativeBins = {
    caveman-proxy = "sha256-O2ep4td+Gqo/ZV5m7wEz18Ka6hOuush4Jn0tgQBE4c4=";
    caveman-engine = "sha256-Skhn8MxrWJR65bBvNglv6s2gZCdfAH/tt25i7607OLo=";
    caveman-mcp = "sha256-TsxSOZYy/hN+8plLc5nT2lHRT3EpjUIoEtfXLmRKCx8=";
    caveman-shrink = "sha256-h4ZsIXH45nR6PUhIGTFalOfr+refE5FImiJIPXyTKqs=";
    caveman-browse = "sha256-rwF//I4rlbZLezEUBs6S/NP0i6ksG1JAPFFlzPZFhGo=";
    cavemem = "sha256-/5FJiOFc/6w2xCvoBg72vQNBCM1ryECS08jGXw7C4k4=";
  };

  installBins = lib.concatLines (
    lib.mapAttrsToList (name: hash: ''
      install -m755 ${
        fetchurl {
          url = "${binBase}/${name}_${goTarget}";
          inherit hash;
          name = name;
        }
      } $out/bin/${name}
    '') nativeBins
  );
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "caveman-cli";
  version = "1.3.4";

  src = fetchurl {
    url = "https://registry.npmjs.org/@caveman-ai/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha512-CVsdg+9Yr0EARvK3zm+2YLJtzo0NAZ9aUsj9/IAvTb89E74MmRSZji3Y4OZrBS4W4jVFYzfoiKkZID/obmPoyA==";
  };

  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = "package";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/@caveman-ai/cli $out/bin
    cp -r dist package.json $out/lib/node_modules/@caveman-ai/cli/
    [ -f LICENSE ] && install -Dm644 LICENSE $out/lib/node_modules/@caveman-ai/cli/LICENSE

    # Native proxy / engine / helper binaries (required for wrap + shrink).
    ${installBins}

    # Expose the native binaries on PATH (caveman resolves them via `which`)
    # and keep `node` available for the CLI's agent/proxy subprocesses.
    makeWrapper ${lib.getExe nodejs} $out/bin/caveman \
      --set CAVEMAN_PKG $out/lib/node_modules/@caveman-ai/cli \
      --prefix PATH : "$out/bin:${lib.makeBinPath [ nodejs ]}" \
      --add-flags "$out/lib/node_modules/@caveman-ai/cli/dist/index.js"
    ln -s $out/bin/caveman $out/bin/cave

    runHook postInstall
  '';

  meta = with lib; {
    description = "Caveman token-shrinking CLI and local proxy for coding agents";
    homepage = "https://github.com/JuliusBrussee/caveman";
    # CLI is MIT; the bundled proxy runtime is BSL-1.1.
    license = with licenses; [
      mit
      unfreeRedistributable
    ];
    mainProgram = "caveman";
    platforms = [ "x86_64-linux" ];
  };
})
