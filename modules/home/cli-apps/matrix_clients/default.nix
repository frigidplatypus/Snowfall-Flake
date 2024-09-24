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
  cfg = config.frgd.cli-apps.matrix_clients;
in
{
  options.frgd.cli-apps.matrix_clients = with types; {
    enable = mkBoolOpt false "matrix_clients";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # iamb
      # gomuks
    ];
  };
}
