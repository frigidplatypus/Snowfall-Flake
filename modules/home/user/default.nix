{ lib, config, pkgs, osConfig ? { }, ... }:
with lib;
with lib.frgd;
let
  inherit (lib) types mkIf mkDefault mkMerge;
  inherit (lib.frgd) mkOpt;

  cfg = config.frgd.user;

  is-linux = pkgs.stdenv.isLinux;
  is-darwin = pkgs.stdenv.isDarwin;

  home-directory = if cfg.name == null then
    null
  else if is-darwin then
    "/Users/${cfg.name}"
  else
    "/home/${cfg.name}";
in {
  options.frgd.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    name =
      mkOpt (types.nullOr types.str) config.frgd.user.name "The user account.";

    fullName = mkOpt types.str "Justin Martin" "The full name of the user.";
    email = mkOpt types.str "jus10mar10@gmail.com" "The email of the user.";

    home = mkOpt (types.nullOr types.str) home-directory
      "The user's home directory.";
  };

  config = mkIf cfg.enable (mkMerge [{
    assertions = [
      {
        assertion = cfg.name != null;
        message = "frgd.user.name must be set";
      }
      {
        assertion = cfg.home != null;
        message = "frgd.user.home must be set";
      }
    ];

    home = {
      username = mkDefault cfg.name;
      homeDirectory = mkDefault cfg.home;
      sessionVariables = { EDITOR = "nvim"; };
      #file.".nix-colors.html".text = ''
      #     <html>
      #   <div style="background-color:#${colorScheme.colors.base00}; height: 200px; width: 30%; float:right;"><p>base00</p>${colorScheme.colors.base00}</div>
      #  <div style="background-color:#${colorScheme.colors.base01}; height: 200px; width: 30%; float:right;"><p>base01</p>${colorScheme.colors.base01}</div>
      #   <div style="background-color:#${colorScheme.colors.base02}; height: 200px; width: 30%; float:right;"><p>base02</p>${colorScheme.colors.base02}</div>
      #   <div style="background-color:#${colorScheme.colors.base03}; height: 200px; width: 30%; float:right;"><p>base03</p>${colorScheme.colors.base03}</div>
      #   <div style="background-color:#${colorScheme.colors.base04}; height: 200px; width: 30%; float:right;"><p>base04</p>${colorScheme.colors.base04}</div>
      #   <div style="background-color:#${colorScheme.colors.base05}; height: 200px; width: 30%; float:right;"><p>base05</p>${colorScheme.colors.base05}</div>
      #   <div style="background-color:#${colorScheme.colors.base06}; height: 200px; width: 30%; float:right;"><p>base06</p>${colorScheme.colors.base06}</div>
      #   <div style="background-color:#${colorScheme.colors.base07}; height: 200px; width: 30%; float:right;"><p>base07</p>${colorScheme.colors.base07}</div>
      #   <div style="background-color:#${colorScheme.colors.base08}; height: 200px; width: 30%; float:right;"><p>base08</p>${colorScheme.colors.base08}</div>
      #   <div style="background-color:#${colorScheme.colors.base09}; height: 200px; width: 30%; float:right;"><p>base09</p>${colorScheme.colors.base09}</div>
      #   <div style="background-color:#${colorScheme.colors.base0A}; height: 200px; width: 30%; float:right;"><p>base0A</p>${colorScheme.colors.base0A}</div>
      #   <div style="background-color:#${colorScheme.colors.base0B}; height: 200px; width: 30%; float:right;"><p>base0B</p>${colorScheme.colors.base0B}</div>
      #   <div style="background-color:#${colorScheme.colors.base0C}; height: 200px; width: 30%; float:right;"><p>base0C</p>${colorScheme.colors.base0C}</div>
      #   <div style="background-color:#${colorScheme.colors.base0D}; height: 200px; width: 30%; float:right;"><p>base0D</p>${colorScheme.colors.base0D}</div>
      #   <div style="background-color:#${colorScheme.colors.base0E}; height: 200px; width: 30%; float:right;"><p>base0E</p>${colorScheme.colors.base0E}</div>
      #   <div style="background-color:#${colorScheme.colors.base0F}; height: 200px; width: 30%; float:right;"><p>base0F</p>${colorScheme.colors.base0F}</div>

      #      </html> 
      # '';

    };

  }]);
}
