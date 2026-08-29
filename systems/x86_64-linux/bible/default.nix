{
  lib,
  modulesPath,
  pkgs,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  environment.systemPackages = [ pkgs.opencode ];

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    tools.git = enabled;
    services.caddy-proxy = {
      enable = true;
      hosts = {
        notes = {
          hostname = "bible.${tailnet}";
          backendAddress = "http://127.0.0.1:3000";
          useTailnet = true;
          extraConfig = "encode gzip";
        };
      };
    };
  };

}
