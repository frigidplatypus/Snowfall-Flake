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
    spaceDir = "/home/justin/mdbible/silverbullet_space";
    user = "justin";
    group = "users";
    package = pkgs.frgd.silverbullet;
  };

  systemd.services.silverbullet.path = [
    pkgs.git
    pkgs.openssh
    pkgs.chromium
  ];

  systemd.services.silverbullet.environment = {
    SB_CHROME_PATH = "${pkgs.chromium}/bin/chromium-browser";
  };
  users.users.justin.extraGroups = [ "silverbullet" ];

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
