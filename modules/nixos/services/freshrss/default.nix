{
  # options,
  config,
  lib,
  # pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.freshrss;
in
{
  options.frgd.services.freshrss = with types; {
    enable = mkBoolOpt false "Whether or not to enable freshrss.";
  };

  config = mkIf cfg.enable {

    sops.secrets.justin_password = { };
    services = {
      freshrss = {
        enable = true;
        defaultUser = "justin";
        baseUrl = "https://freshrss.fluffy-rooster.ts.net";
        # authType = "http_auth";
        virtualHost = "freshrss";
        passwordFile = config.sops.secrets.justin_password.path;
      };
    };
  };
}
