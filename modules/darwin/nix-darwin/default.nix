{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.nix-darwin;
in
{
  options.frgd.nix-darwin = with types; {
    enable = mkBoolOpt false "Whether or not to enable nix-darwin defaults.";
  };

  config = mkIf cfg.enable {

    programs.fish.enable = true;
    environment = {
      shells = with pkgs; [
        bash
        fish
      ];
      systemPackages = [ pkgs.coreutils ];
      systemPath = [ "/opt/homebrew/bin" ];
      pathsToLink = [ "/Applications" ];
    };
    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # Let Determinate manage Nix configuration on macOS when using Determinate's darwin module
    # nix.enable = false;

    nixpkgs.config.allowUnfree = true;
    system = {
      stateVersion = 5;
    };


    # services.nix-daemon.enable = true;
    system.defaults = {
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.InitialKeyRepeat = 14;
      NSGlobalDomain.KeyRepeat = 1;
      dock = {
        autohide = true;
        largesize = 128;
        show-recents = false;
        showhidden = true;
        tilesize = 16;
        wvous-bl-corner = 4;
        wvous-br-corner = 4;
        enable-spring-load-actions-on-all-items = true;
      };
      finder = {
        AppleShowAllExtensions = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 300;
      };
      trackpad = {
        TrackpadThreeFingerDrag = true;
      };
    };

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

  };
}
