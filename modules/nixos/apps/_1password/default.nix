{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.apps._1password;
in {
  options.frgd.apps._1password = with types; {
    enable = mkBoolOpt false "Whether or not to enable 1password.";
  };

  config = mkIf cfg.enable {
    security.pam.services."1password".fprintAuth = true;
    programs = {
      _1password = enabled;
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ config.frgd.user.name ];
      };
    };
  };
}
