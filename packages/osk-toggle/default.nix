{ pkgs, stdenv, ... }:
let
  osk-show = pkgs.writeShellScriptBin "osk-show" ''

     if pidof wvkbd-mobintl > /dev/null; then
       kill -SIGUSR2 "$(pidof wvkbd-mobintl)"
     else
       wvkbd-mobintl &
       sleep 1
    fi

  '';
  osk-hide = pkgs.writeShellScriptBin "osk-hide" ''

    kill -SIGUSR1 "$(pidof wvkbd-mobintl)"

  '';
  osk-toggle = pkgs.writeShellScriptBin "osk-toggle" ''

     if pidof wvkbd-mobintl > /dev/null; then
       kill -SIGRTMIN "$(pidof wvkbd-mobintl)"
     else
       wvkbd-mobintl &
       sleep 1
      kill -SSIGRTMIN "$(pidof wvkbd-mobintl)"
    fi

  '';
in
stdenv.mkDerivation {
  name = "osk-toggle";
  src = osk-show;
  buildInputs = [
    osk-show
    osk-hide
    osk-toggle
  ];
  installPhase = ''
    mkdir -p $out/bin
    cp -r ${osk-show}/bin/osk-show $out/bin/
    cp -r ${osk-hide}/bin/osk-hide $out/bin/
    cp -r ${osk-toggle}/bin/osk-toggle $out/bin/
  '';
}
