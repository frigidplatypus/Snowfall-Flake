{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.sbtask;
in
{
  options.frgd.services.sbtask = with types; {
    enable = mkBoolOpt false "Whether to install sbtask (SilverBullet-backed task CLI) and configure it for the SilverBullet space at notes.fluffy-rooster.ts.net.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sbtask
    ];

    # sbtask reads SB_URL env var (overrides ~/.config/sbtask/config.yaml).
    environment.sessionVariables = {
      SB_URL = "https://notes.fluffy-rooster.ts.net";
    };
  };
}
