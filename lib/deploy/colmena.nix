{ self, overrides ? {}, excludes ? [] }:
let
  hosts = self.nixosConfigurations or {};
  names = builtins.filter (name: !(builtins.elem name excludes)) (builtins.attrNames hosts);
  nodes = builtins.listToAttrs (map (
    name:
      let
        host = hosts.${name};
        override = overrides.${name} or {};
        # Example merging: take host config, then override, then minimal Colmena deployment meta (can expand as needed)
        node = host.config // override // {
          deployment = (
            override.deployment or {
              targetHost = name;
              # targetUser, targetPort, etc can be derived/overridden as needed
            }
          );
          # Example: If you want to inherit meta (pkgs, overlays, etc)
          meta = {
            nixpkgs = host.pkgs;
          };
        };
      in {
        name = name;
        value = node;
      }
    ) names);
in
nodes
