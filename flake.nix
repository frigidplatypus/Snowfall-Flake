{
  description = "My NixOS / nix-darwin / nixos-generators systems";

  inputs = {

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # stable-nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # stable-home-manager = {
    #   url = "github:nix-community/home-manager/release-24.05";
    #   inputs.nixpkgs.follows = "stable-nixpkgs";
    # };

    hyprland = {
      url = "github:hyprwm/Hyprland";
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
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nix-colors.url = "github:misterio77/nix-colors";
    # agenix.url = "github:yaxitech/ragenix";
    neovim = {
      url = "github:justinmartin/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Enable fingerprint reader for T480
    nixos-06cb-009a-fingerprint-sensor = {
      url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;

        src = ./.;
        snowfall = {
          meta = {
            name = "frgd";
            title = "Frigid Platypus";
          };

          namespace = "frgd";
        };
      };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "electron-27.3.11"
          "electron-28.3.3"
          "olm-3.2.16"
        ];
      };
      overlays = with inputs; [

        # There is also a named overlay, though the output is the same.
        snowfall-flake.overlays."package/flake"
        neovim.overlays.default
      ];

      systems.modules.darwin = with inputs; [
        home-manager.darwinModules.home-manager
      ];

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
      ];

      homes.modules = with inputs; [
        sops-nix.homeManagerModules.sops
        xremap-flake.homeManagerModules.default
      ];

      deploy = lib.mkDeploy { inherit (inputs) self; };

      checks = builtins.mapAttrs (
        system: deploy-lib: deploy-lib.deployChecks inputs.self.deploy
      ) inputs.deploy-rs.lib;

      # homes.modules = with inputs; [ sops-nix.homeManagerModules.sops ];

      systems.hosts.t480.modules = with inputs; [ nixos-hardware.nixosModules.lenovo-thinkpad-t480 ];
    };
}
