{
  pkgs,
  modulesPath,
  lib,
  ...
}:
with lib;
with lib.frgd;

{
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];

  frgd = {
    security.sops = enabled;
    services = {
      printing = enabled;
      avahi = enabled;
      tailscale = {
        enable = true;
        autoconnect = enabled;
      };

    };

  };

}
