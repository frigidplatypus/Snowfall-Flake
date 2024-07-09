{
  pkgs,
  modulesPath,
  lib,
  config,
  ...
}:

with lib;
with lib.frgd;
{
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];

  environment.systemPackages = with pkgs; [ neovim ];

  frgd = {
    services = {
      miniflux = enabled;
      tailscale = {
        enable = true;
        autoconnect = enabled;
      };

    };
    security = {
      sops = enabled;
    };
  };

}
