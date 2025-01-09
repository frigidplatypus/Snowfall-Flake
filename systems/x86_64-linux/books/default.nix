{ lib, modulesPath, ... }:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  # Enable networking
  services.caddy = {
    enable = true;
    virtualHosts = {
      "books.fluffy-rooster.ts.net" = {
        extraConfig = ''
          forward_auth unix//run/tailscale-nginx-auth/tailscale-nginx-auth.sock {
            uri /auth
          	header_up Remote-Addr {remote_host}
          	header_up Remote-Port {remote_port}
          	header_up Original-URI {uri}
            	copy_headers {
                Tailscale-User>X-Webauth-User
                Tailscale-Name>X-Webauth-Name
                Tailscale-Login>X-Webauth-Login
                Tailscale-Tailnet>X-Webauth-Tailnet
                Tailscale-Profile-Picture>X-Webauth-Profile-Picture
              }

          }
          reverse_proxy localhost:8083
        '';
      };
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    services = {
      calibre-web = enabled;
      tailscale.tailscaleAuth = enabled;
    };
  };
}
