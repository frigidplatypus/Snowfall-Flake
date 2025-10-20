{
  description = "My NixOS / nix-darwin / nixos-generators systems";

  inputs = {
    # Example: Referencing Determinate Systems' flake for their tooling or nixpkgs
    # Use the official Determinate Systems flake from GitHub. This provides
    # a patched nixpkgs and NixOS modules (nixosModules.default) we can import.
    determinate = {
      url = "github:DeterminateSystems/determinate";
    };

    # This is your standard nixpkgs input, which you might use to import packages
    # If you *don't* want the patched nixpkgs, this should be a standard reference
    # nixpkgs.follows = "determinate/nixpkgs"; # <--- This line is key if you want their nixpkgs version

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable-nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

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
    };
    hyprlock = {
      url = "github:hyprwm/Hyprlock";
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
      url = "github:frigidplatypus/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim_notes = {
      url = "github:frigidplatypus/neovim_notes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    golink = {
      url = "github:tailscale/golink";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Enable fingerprint reader for T480
    nixos-06cb-009a-fingerprint-sensor = {
      url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cria = {
      url = "github:frigidplatypus/cria";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    taskherald = {
      url = "git+ssh://git@github.com/frigidplatypus/taskherald";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    html-to-markdown = {
      url = "github:frigidplatypus/html-to-markdown";
    };

  };

  outputs =
    inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;

        src = ./.;
        flakeRoot = self.outPath;

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
          "ventoy-1.1.05"
          "libsoup-2.74.3"
          # "electron-27.3.11"
          # "electron-28.3.3"
          # "olm-3.2.16"
        ];
      };
      overlays = [

        # There is also a named overlay, though the output is the same.
        inputs.snowfall-flake.overlays."package/flake"
        inputs.neovim.overlays.default
        inputs.neovim_notes.overlays.default
        (final: prev: {
          taskpirate = prev.callPackage ./packages/taskpirate { };
        })
      ];

      systems.modules.darwin = [
        inputs.home-manager.darwinModules.home-manager
      ];

      systems.modules.nixos = [
        inputs.home-manager.nixosModules.home-manager
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
        # brp.nixosModules.default
        # bible-reading-plan.nixosModules.default
        inputs.golink.nixosModules.default
        inputs.vscode-server.nixosModules.default
        inputs.hyprland.nixosModules.default
        inputs.determinate.nixosModules.default
      ];

      homes.modules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.nix-index-database.homeModules.nix-index
        inputs.hyprland.homeManagerModules.default
      ];

      deploy = lib.mkDeploy { inherit (inputs) self; };

      checks = builtins.mapAttrs (
        system: deploy-lib: deploy-lib.deployChecks inputs.self.deploy
      ) inputs.deploy-rs.lib;

      # homes.modules = with inputs; [ sops-nix.homeManagerModules.sops ];

      systems.hosts.t480.modules = [
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480

        # Enable Determinate on this host. This is a minimal module that sets
        # the determinate.enable option to true. If you want to customize more
        # determinate options per-host, add them here.
        (
          { config, pkgs, ... }:
          {
            determinate.enable = true;
          }
        )
      ];
    };
}
