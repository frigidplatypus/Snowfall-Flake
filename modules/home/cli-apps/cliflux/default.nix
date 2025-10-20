{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.cliflux;
in
{
  options.frgd.cli-apps.cliflux = with types; {
    enable = mkBoolOpt false "Whether or not to enable cliflux.";
    server_url = lib.mkOption {
      type = lib.types.str;
      description = "The URL of the Miniflux server including port.";
    };
    api_key_file = lib.mkOption {
      type = lib.types.path;
      description = "The path to the file containing the API key for Miniflux.";
    };
    allow_invalid_certs = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow invalid certificates.";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [ frgd.cliflux ];

  };
}
