{
  description = "CI stub for sbtask";

  outputs = { self }: {
    homeManagerModules.default = { lib, ... }: {
      options.programs.sbtask = {
        enable = lib.mkEnableOption "stub sbtask program";
        settings = lib.mkOption {
          type = lib.types.attrs;
          default = { };
        };
      };
    };
    packages.x86_64-linux.default = derivation {
      name = "sbtask-stub";
      system = "x86_64-linux";
      builder = "/bin/sh";
      args = [ "-c" "mkdir -p $out" ];
    };
  };
}
