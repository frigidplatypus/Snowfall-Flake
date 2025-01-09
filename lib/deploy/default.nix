{
  lib,
  inputs,
  namespace,
}:
let
  inherit (inputs) deploy-rs;
in
{
  ## Create deployment configuration for use with deploy-rs.
  ##
  ## ```nix
  ## mkDeploy {
  ##   inherit self;
  ##   overrides = {
  ##     my-host.system.sudo = "doas -u";
  ##   };
  ## }
  ## ```
  ##
  #@ { self: Flake, overrides: Attrs ? {} } -> Attrs
  mkDeploy =
    {
      self,
      overrides ? { },
    }:
    let
      hosts = self.nixosConfigurations or { };
      excludedHosts = [
        "p5810"
        "t480"
      ];
      # names = builtins.attrNames hosts;
      names = builtins.filter (name: !(builtins.elem name excludedHosts)) (builtins.attrNames hosts);
      # names = builtins.filter (name: name != "p5810") (builtins.attrNames hosts);
      nodes = lib.foldl (
        result: name:
        let
          host = hosts.${name};
          user = host.config.${namespace}.user.name or null;
          inherit (host.pkgs) system;
        in
        result
        // {
          ${name} = (overrides.${name} or { }) // {
            hostname = overrides.${name}.hostname or "${name}";
            profiles = (overrides.${name}.profiles or { }) // {
              system =
                (overrides.${name}.profiles.system or { })
                // {
                  path = deploy-rs.lib.${system}.activate.nixos host;
                }
                // lib.optionalAttrs (user != null) {
                  user = "root";
                  sshUser = user;
                }
                // lib.optionalAttrs (host.config.${namespace}.security.doas.enable or false) { sudo = "doas -u"; };
            };
          };
        }
      ) { } names;
    in
    {
      inherit nodes;
    };
}
