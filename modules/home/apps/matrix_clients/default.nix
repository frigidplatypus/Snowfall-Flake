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
  cfg = config.frgd.apps.matrix_clients;
in
{
  options.frgd.apps.matrix_clients = with types; {
    enable = mkBoolOpt false "matrix_clients";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      element-desktop-wayland
      neochat
      # fluffychat
      nheko
    ];
  };
}
