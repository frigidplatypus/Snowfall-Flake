{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.apps.circuit-python-editors;
in
{
  options.frgd.apps.circuit-python-editors = with types; {
    enable = mkBoolOpt false "Whether or not to enable CircuitPython editors.";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ thonny ]; };
}
