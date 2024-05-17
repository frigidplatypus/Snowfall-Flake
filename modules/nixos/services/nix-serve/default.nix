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
  cfg = config.frgd.services.nix-serve;
in
{
  options.frgd.services.nix-serve = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-serve.";
  };

  config = mkIf cfg.enable {
    frgd.security.sops = enabled;
    sops.secrets.nix_serve_secret = { };
    services = {
      nix-serve = {
        enable = true;
        package = pkgs.nix-serve-ng;
        openFirewall = true;
        secretKeyFile = config.sops.secrets.nix_serve_secret.path;
      };
    };
  };
}
