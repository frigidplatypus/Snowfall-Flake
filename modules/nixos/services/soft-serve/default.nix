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
        initial_admin_keys = [''
          ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM6+N204Jtp7DCXE8vS/8ZZsWPWSIkntc4Q6cvOT7Gkj+kI/duJ/UHdpboj/514h7DerF6Y7H5MOFBvltqmZvEY42mK7PRGE/5i5Jnf7rIHkI5a7ju4hJCGvH8I/7cqPuYu/TTe8OuZCDYDb00WMDYzujW/rAHyffBAbfM0609lRSIf
          BlEY5ijGTksZMWEKzgJpbFXG4XZZju/mLX8O0Hu/PxgDEct7KGpTHYX+pJI9UUL/UQg6KnHxhTBfpdVaX73akyauzL/aXpnFkjHQAixEkupM++pddp16+2k3EtLwHSxspwx//IBTaPIe9pujYPOO5n91DvDeUKuCoJ1jvGy/4iq6Ca7JXLwArbRPrSqET3G1zNPsDY4aekXCwTZ2G/K2Y
          0VnGPFu3+hfea0aBHEGao/GmAHvkRF+SQI2GPG1B5ZR94DW2PI1mtZigUonrNuyu/X5ax/6uoxEJvV8zKpUj4qb2U+ODzmiNwmxIhyxBxoCraW5z9J+mPcPhxirHk= justin@gramarye'']; # Set before initial set up on new machine.  Do not use a key that wil be a user key.
      };
    };
    networking.firewall = {
      allowedTCPPorts = [ 23231 23232 23233 ];
      allowedUDPPorts = [ 23231 23232 23233 ];
    };
  };
}
