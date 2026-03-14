{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.nix-index;
in
{
  options.frgd.services.nix-index = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-index.";
  };

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableBashIntegration = true;
    };
  };
}
