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

  environment.systemPackages = with pkgs; [ neovim ];

  frgd = {
    services = {
      tailscale = {enable = true;
      autoconnect.enable = true;};
      freshrss = enabled;
    };
    security = {
      sops = enabled;
    };
  };

}
