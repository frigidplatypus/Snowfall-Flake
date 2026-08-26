{
  appimageTools,
  fetchurl,
  lib,
  makeDesktopItem,
}:

let
  pname = "logseq";
  version = "2.0.1";

  src = fetchurl {
    url = "https://github.com/logseq/logseq/releases/download/nightly/Logseq-linux-x86_64-${version}.AppImage";
    hash = "sha256-/5eyHztFpmabUr9YTK+pslkgWvv9II28ZmGLxHqiuPo=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "Logseq";
    comment = "A privacy-first platform for knowledge management";
    exec = "${pname} %U";
    icon = pname;
    startupWMClass = "Logseq";
    categories = [ "Utility" ];
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop
    install -Dm644 ${appimageContents}/logseq.png \
      $out/share/icons/hicolor/512x512/apps/${pname}.png
  '';

  meta = with lib; {
    description = "Privacy-first, open-source platform for knowledge management and collaboration";
    homepage = "https://github.com/logseq/logseq";
    license = licenses.agpl3Only;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
