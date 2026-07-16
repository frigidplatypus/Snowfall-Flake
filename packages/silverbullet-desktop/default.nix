{
  lib,
  fetchurl,
  appimageTools,
  makeDesktopItem,
}:

let
  pname = "silverbullet-desktop";
  version = "2.9.0";

  desktopItem = makeDesktopItem {
    name = pname;
    desktopName = "SilverBullet Desktop";
    genericName = "SilverBullet desktop client";
    exec = pname;
    categories = [ "Office" "Network" ];
  };

  src = fetchurl {
    url = "https://releases.silverbullet.plus/releases/${version}/SilverBullet_x86_64.AppImage";
    hash = "sha256-GtiLG6cnZIwwMGjINYEzboCTi+0weUX7zvrtmgA7y4c=";
  };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${desktopItem}/share/applications/${pname}.desktop \
      $out/share/applications/${pname}.desktop
  '';

  meta = with lib; {
    description = "SilverBullet desktop client";
    homepage = "https://silverbullet.md";
    license = licenses.mit;
    maintainers = with maintainers; [ aorith ];
    mainProgram = pname;
    platforms = [ "x86_64-linux" ];
  };
}
