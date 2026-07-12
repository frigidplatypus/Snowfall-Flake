{
  description = "CI stub for silverbullet-mcp";

  outputs = { self }: {
    packages.x86_64-linux.default = derivation {
      name = "silverbullet-mcp-stub";
      system = "x86_64-linux";
      builder = "/bin/sh";
      args = [ "-c" "mkdir -p $out" ];
    };
  };
}
