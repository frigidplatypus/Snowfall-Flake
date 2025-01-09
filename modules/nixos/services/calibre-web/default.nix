{
  lib,
  config,
  options,
  ...
}:

let
  cfg = config.frgd.services.calibre-web;

  inherit (lib) types mkEnableOption mkIf;
in
{
  options.frgd.services.calibre-web = with types; {
    enable = mkEnableOption "calibre-web";
  };

  config = mkIf cfg.enable {
    services.calibre-web = {
      enable = true;
      listen.ip = "127.0.0.1";
      options = {
        enableBookUploading = true;
        enableBookConversion = true;
        enableKepubify = true;
        calibreLibrary = "/books";
        reverseProxyAuth = {
          enable = true;
          header = "X-Webauth-User";
        };
      };
    };

  };
}
