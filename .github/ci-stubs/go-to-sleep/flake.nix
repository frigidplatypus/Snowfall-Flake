{
  description = "CI stub for go-to-sleep";

  outputs = { self }: {
    homeModules.default = { };
    packages.x86_64-linux.default = derivation {
      name = "go-to-sleep-stub";
      system = "x86_64-linux";
      builder = "/bin/sh";
      args = [
        "-c"
        "mkdir -p $out"
      ];
    };
  };
}
