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

  services.silverbullet = {
    enable = true;
    spaceDir = "/home/justin/silverbullet";
    user = "justin";
    group = "users";
  };

  systemd.services.silverbullet.path = [
    pkgs.git
    pkgs.openssh
  ];
  users.users.justin.extraGroups = [ "silverbullet" ];

  environment.systemPackages = [ pkgs.opencode];

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    tools.git = enabled;
    services.caddy-proxy = {
      enable = true;
      hosts = {
        notes = {
          hostname = "notes.${tailnet}";
          backendAddress = "http://127.0.0.1:3000";
          useTailnet = true;
          extraConfig = "encode gzip";
        };
      };
    };
  };

}
