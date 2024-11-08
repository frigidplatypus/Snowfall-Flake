{
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.security.doas;
in
{
  options.frgd.security.doas = {
    enable = mkBoolOpt false "Whether or not to replace sudo with doas.";
  };

  config = mkIf cfg.enable {

    # Enable and configure `doas`.
    security.doas = {
      enable = true;
      extraRules = [
        {
          users = [ config.frgd.user.name ];
          noPass = true;
          keepEnv = true;
        }
      ];
    };

    # Add an alias to the shell for backward-compat and convenience.
  };
}
