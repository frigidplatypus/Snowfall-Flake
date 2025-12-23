{ lib, ... }:

with lib;
rec {
  ## Create a NixOS module option.
  ##
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;

  ## Create a boolean NixOS module option.
  ##
  ## ```nix
  ## lib.mkBoolOpt true "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt = mkOpt types.bool;

  ## Create a boolean NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;

  tailnet = "fluffy-rooster.ts.net";
  tsidpUrl = "https://dns.${tailnet}:8443";
  # font-mono = " Iosevka Nerd Font Mono";
  # font = "Iosevka Nerd Font Propo";

  # font = "FiraCode Nerd Font";
  font = "MononokiNerdFont";

  flakeRoot = self.outPath;
  font-mono = "${font}Mono";
  font-propo = "${font}Propo";

  icon-theme = "Gruvbox Plus Dark";

  # font-mono = "Agave Nerd Font Mono";
  # font = "Agave Nerd Font";

  enabled = {

    ## Quickly enable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ true
    enable = true;
  };

  disabled = {
    ## Quickly disable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ false
    enable = false;
  };
}
