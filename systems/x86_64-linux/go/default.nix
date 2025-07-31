{
  lib,
  config,
  modulesPath,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Enable networking

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
