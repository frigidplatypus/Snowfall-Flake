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
  cfg = config.frgd.tools.sanoid;
in
{
  options.frgd.tools.sanoid = with types; {
    enable = mkBoolOpt false "Whether or not to enable sanoid.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sanoid
      lzo
      mbuffer
      pv
      #frgd.nix-update-index
    ];
  };
}
