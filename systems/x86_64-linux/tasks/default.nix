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

  environment.systemPackages = with pkgs; [
    devenv
    direnv
  ];

  # Enable networking
  frgd = {
    archetypes.lxc = enabled;
    virtualization.docker = enabled;
    cli-apps.tmux = enabled;
    security.sops = enabled;
    services = {
      taskchampion = {
        enable = true;
      };
    };
  };
  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "tasks.fluffy-rooster.ts.net:8000";
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "tasks.${tailnet}" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:10222
          encode gzip
        '';
      };
      "tasks.${tailnet}:8000" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:3456
          encode gzip
        '';
      };
    };
  };
}
