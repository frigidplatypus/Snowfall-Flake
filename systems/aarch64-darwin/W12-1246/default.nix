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
  services.nix-daemon.enable = true;
  environment.shells = with pkgs; [
    fish
    zsh
  ];
  environment.systemPackages = with pkgs; [
    inputs.fh.packages.aarch64-darwin.default
    devenv
  ];
  frgd = {
    homebrew = {
      enable = true;
      casks.enable = true;
    };

    nix-darwin = enabled;
  };
}
