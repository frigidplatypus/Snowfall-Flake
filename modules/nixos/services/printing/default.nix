{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.printing;
in
{
  options.frgd.services.printing = with types; {
    enable = mkBoolOpt false "Whether or not to configure printing support.";
    gui = mkBoolOpt false "Whether or not to enable a gui to configure printing support.";
    openFirewall = mkBoolOpt false "Whether or not to open firewall for printing";
    colorPrinter = mkBoolOpt false "Whether or not to configure the color printer";

  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
      openFirewall = (mkIf cfg.openFirewall) true;
      #listenAddresses = [ "*:631" ];
    };

    #environment.systemPackages = (mkIf cfg.gui) [ pkgs.system-config-printer ];

    hardware.printers = mkIf cfg.colorPrinter {
      ensurePrinters = [
        {
          name = "Color Printer";
          location = "Home";
          deviceUri = "dnssd://ColorPrinter._pdl-datastream._tcp.local/";
          # model = ./Ricoh-Aficio_SP_C430DN-Postscript-Ricoh.ppd;
        }
      ];
      ensureDefaultPrinter = "Color Printer";
    };
    environment.systemPackages = with pkgs; [ gutenprint ];
  };
}
