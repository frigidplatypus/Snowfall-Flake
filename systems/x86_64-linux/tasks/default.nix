{ lib, modulesPath, ... }:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Enable networking

  frgd = {
    archetypes.lxc = enabled;
    services = {
      taskchampion = {
        enable = true;
      };
    };
  };
}
