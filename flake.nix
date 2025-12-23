{
  description = "My NixOS / nix-darwin / nixos-generators systems";

  inputs = {
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3.13.2.tar.gz";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable-nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena.url = "github:zhaofengli/colmena";
    # ... (other inputs trimmed for brevity) ...
  };

  outputs = inputs: let
    lib = inputs.snowfall-lib.mkLib {
      inherit inputs;
      src = ./.;
      flakeRoot = inputs.self.outPath;
      snowfall = {
        meta = {
          name = "frgd";
          title = "Frigid Platypus";
        };
        namespace = "frgd";
      };
    };
  in {
    colmenaHive = inputs.colmena.lib.makeHive (
      import ./lib/deploy/colmena.nix {
        self = inputs.self;
        overrides = {}; # Can customize as needed
        excludes = [];  # Can customize as needed
      }
    );

    # Existing mkFlake output:
    # You may want to change this key to "default" if that's what your Nix infra expects
    default = lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ "ventoy-1.1.05" "libsoup-2.74.3" ];
      };
      overlays = [
        inputs.snowfall-flake.overlays."package/flake"
        inputs.neovim.overlays.default
        inputs.neovim_notes.overlays.default
        (final: prev: { taskpirate = prev.callPackage ./packages/taskpirate { }; })
      ];
      systems.modules.darwin = [ inputs.home-manager.darwinModules.home-manager ];
      systems.modules.nixos = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.default
        inputs.golink.nixosModules.default
        inputs.vscode-server.nixosModules.default
        inputs.determinate.nixosModules.default
      ];
      homes.modules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.homeModules.nix-index
        inputs.taskherald.homeManagerModules.default
      ];
      systems.hosts.t480.modules = [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
        ({ config, pkgs, ... }: { determinate.enable = true; })
      ];
    };
  };
}
