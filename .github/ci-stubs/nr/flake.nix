{
  description = "CI stub for nr";

  outputs = { self }: {
    packages.x86_64-linux.default = derivation {
      name = "nr-stub";
      system = "x86_64-linux";
      builder = "/bin/sh";
      args = [ "-c" "mkdir -p $out" ];
    };
  };
}
