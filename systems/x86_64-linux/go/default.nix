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
  services.golink.enable = true;

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
  };
}
