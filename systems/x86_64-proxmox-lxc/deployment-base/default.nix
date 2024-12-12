{
  modulesPath,
  lib,
  ...
}:

with lib;
with lib.frgd;
{
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];

  frgd = {
    services = {
      tailscale = {
        enable = true;
        autoconnect.enable = true;
      };
    };
    security = {
      sops = enabled;
    };
  };

}
