{ options, config, lib, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.system.xkb;
in {
  options.frgd.system.xkb = with types; {
    enable = mkBoolOpt false "Whether or not to configure xkb.";
  };

  config = mkIf cfg.enable {
    console.useXkbConfig = true;
    services.xserver.xkb = {
      layout = "us";
      options = "caps:escape";
    };
  };
}
