{
  config,
  pkgs,
  options,
  lib,
  ...
}:
with lib;
with lib.frgd;
{

  networking.firewall.enable = false;
  services.openssh.permitRootLogin = lib.mkForce "yes";
  services.qemuGuestAgent.enable = true;
  services.getty.autologinUser = "justin";
  security.sudo.wheelNeedsPassword = false;

  frgd = {
    suites.installer = enabled;
  };
}
