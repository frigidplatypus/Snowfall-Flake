{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.nix;

  substituters-submodule = types.submodule (
    { name, ... }:
    {
      options = with types; {
        key = mkOpt (nullOr str) null "The trusted public key for this substituter.";
      };
    }
  );
in
{
  options.frgd.nix = with types; {
    enable = mkBoolOpt true "Whether or not to manage nix configuration.";
    # package = mkOpt package pkgs.nixVersions.latest "Which nix package to use.";

    github-access-token = {
      enable = mkBoolOpt false "Whether to enable GitHub access token via SOPS";
    };

    default-substituter = {
      url = mkOpt str "https://cache.nixos.org" "The url for the substituter.";
      key =
        mkOpt str "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "The trusted public key for the substituter.";
    };

    extra-substituters = mkOpt (attrsOf substituters-submodule) {
    } "Extra substituters to configure.";

    generateRegistryFromInputs = mkBoolOpt false "Whether to populate the flake registry from inputs during evaluation.";
    generateNixPathFromInputs = mkBoolOpt false "Whether to populate NIX_PATH from inputs during evaluation.";
    linkInputs = mkBoolOpt false "Whether to link flake inputs into the store at evaluation time.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = mapAttrsToList (name: value: {
        assertion = value.key != null;
        message = "frgd.nix.extra-substituters.${name}.key must be set";
      }) cfg.extra-substituters;

      environment.systemPackages = with pkgs; [
        nixfmt-rfc-style
        nix-index
        nix-prefetch-git
        nix-output-monitor
      ];

      nix =
        let
          users = [
            "root"
            config.frgd.user.name
          ]
          ++ optional config.services.hydra.enable "hydra";
          extraSubstituterUrls = mapAttrsToList (name: _value: name) cfg.extra-substituters;
          extraSubstituterKeys = mapAttrsToList (_name: value: value.key) cfg.extra-substituters;
        in
        {
          # package = cfg.package;

          settings = {
            experimental-features = "nix-command flakes";
            # http-connections = 500;
            warn-dirty = false;
            log-lines = 50;
            sandbox = "relaxed";
            auto-optimise-store = true;
            eval-cache = true;
            trusted-users = users;
            allowed-users = users;
            download-buffer-size = 1024 * 1024 * 1024;

            substituters = [
              cfg.default-substituter.url
            ]
            ++ extraSubstituterUrls;
            trusted-public-keys = [
              cfg.default-substituter.key
            ]
            ++ extraSubstituterKeys;
          }
          // (lib.optionalAttrs config.frgd.tools.direnv.enable {
            keep-outputs = true;
            keep-derivations = true;
          });

          # Include GitHub access tokens from SOPS template
          extraOptions = lib.optionalString cfg.github-access-token.enable ''
            !include ${config.sops.templates.github_access_tokens.path}
          '';

          # flake-utils-plus
          generateRegistryFromInputs = cfg.generateRegistryFromInputs;
          generateNixPathFromInputs = cfg.generateNixPathFromInputs;
          linkInputs = cfg.linkInputs;
        };

      system.stateVersion = "24.05";
    }

    # SOPS secrets for GitHub access token
    (mkIf cfg.github-access-token.enable {
      # The actual secret containing the token value
      sops.secrets.github_api_token = {
        mode = "0400";
      };

      # Template to create the access tokens file that nix.conf will include
      sops.templates.github_access_tokens = {
        content = ''
          access-tokens = github.com=${config.sops.placeholder.github_api_token}
        '';
        mode = "0440";
        group = config.users.groups.keys.name;
      };
    })
  ]);
}
