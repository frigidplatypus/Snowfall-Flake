{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.security.sops;
in
{
  options.frgd.security.sops = with types; {
    enable = mkBoolOpt false "Whether or not to enable sops.";

    taskwarrior = {
      enable = mkBoolOpt false "Whether or not to enable automatic connection to Tailscale";
    };
    wireguard_server_key = {
      enable = mkBoolOpt false "Whether or not to enable Wireguard server key";
    };

    vultr_api_key = {
      enable = mkBoolOpt false "Vultr API Key";
    };
    namecheap_api_key = {
      enable = mkBoolOpt false "Namecheap API Key";
    };
    porkbun = {
      enable = mkBoolOpt false "Namecheap API Key";
    };
    matrix_registration_shared_secret = {
      enable = mkBoolOpt false "Matrix Registration Shared Secret";
    };
    github_access_token = {
      enable = mkBoolOpt false "GitHub Access Token for Nix";
    };

  };

  config = mkIf cfg.enable (mkMerge [
    {

      environment.systemPackages = with pkgs; [ sops ];
      sops.defaultSopsFile = ./secrets.yaml;
      sops.defaultSopsFormat = "yaml";
      sops.age.keyFile = "/sops/keys.txt";
      # Disable SSH host key paths - use only age key for decryption
      # This prevents errors during installation when SSH keys don't exist yet
      sops.age.sshKeyPaths = [ ];
      sops.secrets.tailscale_api_key = {
        owner = "root";
        group = "tailscale";
        mode = "0640";
      };
      sops.secrets.justin_password = { };
      # Ensure the tailscale group exists so files created with group=tailscale
      # on the target will validate and be created with the correct group.
      users.groups.tailscale = { };
      #sops.templates.justin_password.contents = ''
      #  adminPass = "${config.sops.placeholder.justin_password}"
      #'';
    }
    (mkIf (cfg.taskwarrior.enable) {
      sops.secrets.taskwarrior_ca_cert = {
        owner = "justin";
        # group = "taskd";
        mode = "0440";
        #       path = "/home/justin/.taskcerts/taskwarrior_ca_cert";
      };
      sops.secrets.taskwarrior_private_key = {
        owner = "justin";
        # group = "taskd";
        mode = "0440";
        #      path = "/home/justin/.taskcerts/taskwarrior_private_key";
      };
      sops.secrets.taskwarrior_public_cert = {
        owner = "justin";
        # group = "taskd";
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
