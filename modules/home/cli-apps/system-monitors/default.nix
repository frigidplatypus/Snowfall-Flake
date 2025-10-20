{ lib, config, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.system-monitors;
in
{
  options.frgd.cli-apps.system-monitors = with types; {
    enable = mkBoolOpt false "Whether or not to enable system monitors.";
  };

  config = mkIf cfg.enable {
    # programs.htop = enabled;
    programs.btop = enabled;
    programs.bottom = enabled;
  };
}
