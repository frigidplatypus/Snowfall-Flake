{ lib, config, inputs, ... }:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.security.agenix;
  inherit (inputs) agenix;
in {
  options.frgd.security.agenix = {
    enable = mkEnableOption "Agenix";

    taskwarrior = {
      enable = mkBoolOpt false
        "Whether or not to enable automatic connection to Tailscale";
    };

    vultr_api_key = { enable = mkiEnableOption "Vultr API Key"; };

  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ agenix ];

    age = mkIf cfg.taskwarrior.enable {

      secrets."taskwarrior.ca.cert.age" = {
        file = ../../../../secrets/taskwarrior.ca.cert.age;
        mode = "770";
        owner = "justin";
      };
      secrets."taskwarrior.public.certificate.age" = {
        file = ../../../../secrets/taskwarrior.public.certificate.age;
        mode = "770";
        owner = "justin";
      };
      secrets."taskwarrior.private.key.age" = {
        file = ../../../../secrets/taskwarrior.private.key.age;
        mode = "770";
        owner = "justin";
      };
    };

  };
}
