{
  lib,
  modulesPath,
  pkgs,
  config,
  inputs,
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
    spaceDir = "/home/justin/silverbullet-spaces";
    user = "justin";
    group = "users";
    # upstream-tracking fork (packages/silverbullet): currently 3.0.0, ahead
    # of nixpkgs' 2.12.1. Bump = version + 3 hashes.
    package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.silverbullet;
  };

  systemd.services.silverbullet.path = [
    pkgs.git
    pkgs.openssh
    pkgs.chromium
  ];

  systemd.services.silverbullet.environment = {
    SB_CHROME_PATH = "${pkgs.chromium}/bin/chromium-browser";
  };
  users.users.justin = {
    extraGroups = [ "silverbullet" ];
    linger = true;
  };

  environment.systemPackages = [ pkgs.opencode ];

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    tools.git = enabled;
    virtualization.docker = enabled;
    services = {
      caddy-proxy = {
        enable = true;
        hosts.notes = {
          tailnetHostname = "notes.${tailnet}";
          backendAddress = "http://127.0.0.1:3000";
        };
      };
    };
  };

}
