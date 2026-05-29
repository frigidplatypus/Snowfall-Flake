{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "numara";
  # Update hashes for both Linux and Darwin!
  version = "6.10.5";

  src = fetchurl {
    url = "https://github.com/bornova/numara-calculator/releases/download/v${version}/Numara-${version}-x86_64.AppImage";
    hash = "sha256-GMBF2tSdYMA2L/4hb4svwNOpO6V47gFJdAHEB3aRHaw=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;
  #    mv $out/bin/{${pname}-${version},${pname}}

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/numara.desktop $out/share/applications/Numara.desktop
    install -Dm444 ${appimageContents}/numara.png $out/share/pixmaps/Numara.png
    substituteInPlace $out/share/applications/Numara.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' 'Exec=numara'
  '';

}
