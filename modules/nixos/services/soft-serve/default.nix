{ config, lib, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.services.soft-serve;
in {
  options.frgd.services.soft-serve = with types; {
    enable = mkBoolOpt false "Whether or not to configure soft-serve support.";
  };

  config = mkIf cfg.enable {
    services.soft-serve = {
      enable = true;
      settings = {
        name = "FRGD Repo";
        ssh.public_url = "ssh://git.frgd.us:23231";
        initial_admin_keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICLUmRA2xE2ff5Z8pW/I/vKVgWnFKV71vArcdYD+OfIH justin@gramarye"
        ]; # Set before initial set up on new machine.  Do not use a key that wil be a user key.
      };
    };
    networking.firewall = {
      allowedTCPPorts = [ 23231 ]; # 23232 23233 ];
      allowedUDPPorts = [ 23231 ]; # 23232 23233 ];
    };
  };
}
