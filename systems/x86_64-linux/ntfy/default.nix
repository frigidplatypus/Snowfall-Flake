{
  lib,
  modulesPath,
  pkgs,
  config,
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
    archetypes.lxc = enabled;
    cli-apps.tmux = enabled;
    security.sops = enabled;
    services.tailscale = {
      enable = true;
      autoconnect = enabled;
    };

  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      behind-proxy = true;
      upstream-base-url = "https://ntfy.sh";
      base-url = "https://ntfy.${tailnet}";
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "ntfy.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:2586
          encode gzip
        '';
      };
    };
  };
}
