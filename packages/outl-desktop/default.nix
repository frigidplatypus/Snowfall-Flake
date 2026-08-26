{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:

let
  pname = "outl-desktop";
  version = "0.12.0-beta.168";

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "outl Desktop";
    genericName = "outl desktop client";
    exec = pname;
    categories = [
      "Office"
      "Network"
    ];
  };

  src = fetchurl {
    url = "https://github.com/outlmd/outl/releases/download/v${version}/outl-desktop-linux-x86_64.AppImage";
    hash = "sha256-5v+lY6VwGHzY99oNhD+3pz9/vLsGMiNnywh59o476Vk=";
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop
  '';

  meta = with lib; {
    description = "Local-first outliner desktop client with CRDT sync";
    homepage = "https://outl.app";
    license = licenses.mit;
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
