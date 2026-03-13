{
  lib,
  modulesPath,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  networking.firewall.enable = false;

  sops.secrets.open-webui-environment = {
    mode = "0660";
    group = "open-webui";
  };

  services.open-webui = {
    enable = true;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://p5810:11434";
    };
    environmentFile = config.sops.secrets.open-webui-environment.path;

  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    services.caddy-proxy = {
      enable = true;
      hosts = {
        ai = {
          hostname = "ai.${tailnet}";
          backendAddress = "http://127.0.0.1:8080";
          useTailnet = true;
          extraConfig = "encode gzip";
        };
      };
    };
  };
}
