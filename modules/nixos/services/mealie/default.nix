{
  lib,
  config,
  options,
  ...
}:

let
  cfg = config.frgd.services.mealie;

  inherit (lib) types mkEnableOption mkIf;
in
{
  options.frgd.services.mealie = with types; {
    enable = mkEnableOption "mealie";
  };

  config = mkIf cfg.enable {
    services.mealie = {
      enable = true;
      listenAddress = "127.0.0.1";
    };

  };
}
