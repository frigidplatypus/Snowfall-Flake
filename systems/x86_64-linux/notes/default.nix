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

  services.tailscale.serve = {
    enable = true;
    services.logseq = {
      endpoints."tcp:443" = "http://127.0.0.1:8787";
      advertised = true;
    };
  };

  environment.systemPackages = [ pkgs.opencode ];

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    tools.git = enabled;
    virtualization.docker = enabled;
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
