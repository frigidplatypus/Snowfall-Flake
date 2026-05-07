{
  lib,
  modulesPath,
  config,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  networking.firewall.enable = false;

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    services.openssh = mkForce disabled;
  };

  services.openssh = enabled;
}
