{ inputs, lib, config, pkgs, ... }:
with lib;
with lib.frgd; {
  services.nix-daemon.enable = true;
  environment.shells = with pkgs; [ fish zsh ];
  environment.systemPackages = with pkgs;
    [ inputs.fh.packages.x86_64-darwin.default ];
  frgd = {
    homebrew = {
      enable = true;
      casks.enable = true;
    };

    homebrew = { casks = [ "openssl@3" ]; };

    nix-darwin = enabled;
  };
}

