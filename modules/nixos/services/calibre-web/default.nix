{
  lib,
  config,
  pkgs,
  options,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.calibre-web;
in
{
  options.frgd.services.calibre-web = with types; {
    enable = mkBoolOpt false "Whether or not to enable calibre-web.";
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
    environment.systemPackages = with pkgs; [
      calibre
      calibre-web
    ];

  };
}
