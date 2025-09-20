{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
  let
    cfg = config.frgd.desktop.addons.mako;
  in
  {
    options.frgd.desktop.addons.mako = with types; {
      enable = mkBoolOpt false "Whether or not to enable mako.";
    };

  config = mkIf cfg.enable {

    home = {
      packages = with pkgs; [ libnotify ];
    };
    services.mako = {
      enable = true;
      settings = {
        backgroundColor = "#${colorScheme.palette.base09}";
        borderColor = "#${colorScheme.palette.base0F}";
        defaultTimeout = 15000;
      };
    };
  };
}
