{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.nix-ld;
in
{
  options.frgd.tools.nix-ld = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-ld.";
  };

  config = mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        glib
        nss
        nspr
        atk
        at-spi2-atk
        at-spi2-core
        cups
        libdrm
        libxkbcommon
        libGL
        pango
        cairo
        gtk3
        expat
        dbus
        libxshmfence
        udev
        alsa-lib
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxrandr
        libxshmfence
        mesa
        libgbm
        freetype
        zlib
        fontconfig
      ];
    };
  };
}
