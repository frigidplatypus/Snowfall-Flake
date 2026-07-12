{
  description = "CI stub for silverbullet-api-gateway";

  outputs = { self }: {
    homeManagerModules.default = { lib, ... }: {
      options.services.silverbullet-api-gateway = {
        enable = lib.mkEnableOption "stub silverbullet-api-gateway service";
        package = lib.mkOption {
          type = lib.types.nullOr lib.types.package;
          default = null;
        };
        sbUrl = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        sbToken = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        sbPage = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        dataPattern = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        separator = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        journalPattern = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
        inboxPage = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };
      };
    };
    packages.x86_64-linux.default = derivation {
      name = "silverbullet-api-gateway-stub";
      system = "x86_64-linux";
      builder = "/bin/sh";
      args = [ "-c" "mkdir -p $out" ];
    };
  };
}
