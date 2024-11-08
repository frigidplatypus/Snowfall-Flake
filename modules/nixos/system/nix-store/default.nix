{
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.system.nix-store;
in
{
  options.frgd.system.nix-store = with types; {
    enable = mkBoolOpt false "Whether or not to enable to cache on tsnix.";
  };

  config = mkIf cfg.enable {
    frgd.nix.extra-substituters = {
      "https://nasnix.fluffy-rooster.ts.net:5000".key = "frgd:Iurj/2/DemnBejCyQWFra3+FKWIEEEnixqe9kwMvbmY=";
    };
  };
}
