{ lib, fetchurl, appimageTools }:

let
  pname = "numara";
  # Update hashes for both Linux and Darwin!
  version = "5.0.1";

  src = fetchurl {
    url =
      "https://github.com/bornova/numara-calculator/releases/download/v${version}/Numara-${version}-x86_64.AppImage";
    hash = "sha256-snMYWVCbnB3w3kvtgyziqnRKVmWBKiE/OWpyhP3m1hY=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in appimageTools.wrapType2 rec {
  inherit pname version src;
  #    mv $out/bin/{${pname}-${version},${pname}}

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/numara.desktop $out/share/applications/Numara.desktop
    install -Dm444 ${appimageContents}/usr/share/icons/hicolor/256x256/apps/numara.png $out/share/pixmaps/Numara.png
    substituteInPlace $out/share/applications/Numara.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=numara'
  '';

}
