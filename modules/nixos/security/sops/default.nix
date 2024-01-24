{ lib, config, pkgs, ... }:
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
    namecheap_api_key = { enable = mkBoolOpt false "Namecheap API Key"; };
    porkbun = { enable = mkBoolOpt false "Namecheap API Key"; };
    matrix_registration_shared_secret = {
      enable = mkBoolOpt false "Matrix Registration Shared Secret";
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {

      environment.systemPackages = with pkgs; [ sops ];
      sops.defaultSopsFile = ./secrets.yaml;
      sops.defaultSopsFormat = "yaml";
      sops.age.keyFile = "/home/justin/.config/sops/age/keys.txt";
      sops.secrets.tailscale_api_key = { };
      sops.secrets.justin_password = { };
    }
    (mkIf (cfg.taskwarrior.enable) {
      sops.secrets.taskwarrior_ca_cert = {
        owner = "justin";
        group = "taskd";
        mode = "0440";
        #       path = "/home/justin/.taskcerts/taskwarrior_ca_cert";
      };
      sops.secrets.taskwarrior_private_key = {
        owner = "justin";
        group = "taskd";
        mode = "0440";
        #      path = "/home/justin/.taskcerts/taskwarrior_private_key";
      };
      sops.secrets.taskwarrior_public_cert = {
        owner = "justin";
        group = "taskd";
        mode = "0440";
        #     path = "/home/justin/.taskcerts/taskwarrior_public_cert";
      };

    })
    (mkIf (cfg.wireguard_server_key.enable) {
      sops.secrets.wireguard_server_private_key = { };
    })
    (mkIf (cfg.vultr_api_key.enable) { sops.secrets.vultr_api_key = { }; })
    (mkIf (cfg.porkbun.enable) { sops.secrets.porkbun_api_key = { }; })
    (mkIf (cfg.namecheap_api_key.enable) {
      sops.secrets.namecheap_api_key = { };
    })
    (mkIf (cfg.matrix_registration_shared_secret.enable) {
      sops.secrets.matrix_registration_shared_secret = {
        owner = "matrix-synapse";
      };
    })
  ]);
}
