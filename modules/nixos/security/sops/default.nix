{ lib, config, ... }:
with lib;
with lib.frgd;
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.frgd.security.sops;
in {
  options.frgd.security.sops = {
    enable = mkEnableOption "sops";

    taskwarrior = {
      enable = mkBoolOpt false
        "Whether or not to enable automatic connection to Tailscale";
    };
    wireguard_server_key = {
      enable = mkBoolOpt false "Whether or not to enable Wireguard server key";
    };

    vultr_api_key = { enable = mkBoolOpt false "Vultr API Key"; };
    matrix_registration_shared_secret = {
      enable = mkBoolOpt false "Matrix Registration Shared Secret";
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {
      sops.defaultSopsFile = ./secrets.yaml;
      sops.defaultSopsFormat = "yaml";
      sops.age.keyFile = "/home/justin/.config/sops/age/keys.txt";
    }
    (mkIf (cfg.taskwarrior.enable) {
      sops.secrets.taskwarrior_ca_cert = {
        owner = "justin";
        #       path = "/home/justin/.taskcerts/taskwarrior_ca_cert";
      };
      sops.secrets.taskwarrior_private_key = {
        owner = "justin";
        #      path = "/home/justin/.taskcerts/taskwarrior_private_key";
      };
      sops.secrets.taskwarrior_public_cert = {
        owner = "justin";
        #     path = "/home/justin/.taskcerts/taskwarrior_public_cert";
      };

    })
    (mkIf (cfg.wireguard_server_key.enable) {
      sops.secrets.wireguard_server_private_key = { };
    })
    (mkIf (cfg.vultr_api_key.enable) { sops.secrets.vultr_api_key = { }; })
    (mkIf (cfg.matrix_registration_shared_secret.enable) {
      sops.secrets.matrix_registration_shared_secret = {
        owner = "matrix-synapse";
      };
    })
  ]);
}
