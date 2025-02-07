{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.suites.installer;
in
{
  options.frgd.suites.installer = with types; {
    enable = mkBoolOpt false "Whether or not to enable installer configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fish
      frgd.neovim
      disko
      nixos-anywhere
    ];

    networking.firewall.enable = false;
    services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
    services.getty.autologinUser = "justin";
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
    networking = {
      # networkmanager = enabled;
      wireless = enabled;
    };

    frgd = {
      nix = enabled;

      services = {
        openssh = enabled;
        avahi = enabled;
      };
    };
  };
}
