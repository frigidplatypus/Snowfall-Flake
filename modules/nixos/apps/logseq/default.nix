{
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.apps.logseq;
in
{
  options.frgd.apps.logseq = with types; {
    enable = mkBoolOpt false "Whether or not to enable logseq.";
  };

  config = mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [ logseq ];
    environment.systemPackages = with pkgs; [
      #logseq
      (logseq.override { electron = electron_39; })
    ];
    # services.flatpak = {
    #   enable = true;
    #   packages = [
    #     "com.logseq.Logseq"
    #   ];
    # };

  };

}
