{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
{
  # services.nix-daemon.enable = true;
  environment.shells = with pkgs; [
    fish
    zsh
  ];
  environment.systemPackages = with pkgs; [
    devenv
    nixfmt-rfc-style
  ];
  frgd = {
    homebrew = {
      enable = true;
      casks.enable = true;
    };

    nix-darwin = enabled;
  };
  nixpkgs.config.allowBroken = true;
  nix.settings.trusted-users = [
    "jmartin"
    "root"
  ];
}
