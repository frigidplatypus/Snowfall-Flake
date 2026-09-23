{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.ai-tools;
in
{
  options.frgd.cli-apps.ai-tools = with types; {
    enable = mkBoolOpt false "Whether or not to enable ai-tools.";
  };

  config = mkIf cfg.enable {
    frgd.cli-apps.opencode.enable = mkDefault true;
    home.packages = with pkgs; [
      gemini-cli
      # crush
      github-copilot-cli
    ];
  };
}
