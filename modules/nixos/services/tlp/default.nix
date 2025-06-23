{
  options,
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.tlp;
in
{
  options.frgd.services.tlp = with types; {
    enable = mkBoolOpt false "tlp";
  };

  config = mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 50;

        CPU_BOOST_ON_BAT = 0;
        START_CHARGE_THRESH_BAT0 = 50;
        STOP_CHARGE_THRESH_BAT0 = 90;
        RUNTIME_PM_ON_BAT = "auto";
      };
    };

  };
}
