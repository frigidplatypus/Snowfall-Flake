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
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  services.qemuGuest = {
    enable = true;
  };
  services.getty.autologinUser = "justin";
  security.sudo.wheelNeedsPassword = false;

  frgd = {

    suites.installer = enabled;
  };
}
