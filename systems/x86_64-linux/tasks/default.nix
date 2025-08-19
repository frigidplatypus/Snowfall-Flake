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
    virtualization.docker = enabled;
    # services = {
    #   taskchampion = {
    #     enable = true;
    #   };
    # };
  };
  services.vikunja = {
    enable = true;
    frontendScheme = "https";
    frontendHostname = "tasks.fluffy-rooster.ts.net";

  };
  services.caddy = {
    enable = true;
    virtualHosts = {
      # "tasks.fluffy-rooster.ts.net:10222" = {
      #   extraConfig = ''
      #     reverse_proxy http://127.0.0.1:10222
      #     encode gzip
      #   '';
      # };
      "tasks.fluffy-rooster.ts.net" = {
        extraConfig = ''
          reverse_proxy http://127.0.0.1:3456
          encode gzip
        '';
      };
    };
  };
}
