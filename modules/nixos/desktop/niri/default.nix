{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.niri;
  niriPkg = config.programs.niri.package;
in
{
  disabledModules = [ "programs/wayland/niri.nix" ];

  options.frgd.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable the niri window manager.";
  };

  options.programs.niri = {
    enable = mkEnableOption "niri";
    package = mkOption {
      type = types.package;
      default = pkgs.niri-unstable;
      description = "The niri package to use.";
    };
  };

  options.niri-flake.cache.enable = mkEnableOption "the niri-flake binary cache" // {
    default = true;
  };

  config = mkMerge [
    (mkIf config.niri-flake.cache.enable {
      nix.settings = {
        substituters = [ "https://niri.cachix.org" ];
        trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
      };
    })
    (mkIf cfg.enable {
      programs.niri.enable = true;
      environment.systemPackages = with pkgs; [
        xdg-utils
        niriPkg
      ];

      programs.dms-shell.enable = true;

      services.dbus.enable = true;

      environment.sessionVariables = {
        XCURSOR_THEME = "Capitaine Cursors (Gruvbox)";
      };

      xdg = {
        autostart.enable = mkDefault true;
        menus.enable = mkDefault true;
        mime.enable = mkDefault true;
        icons.enable = mkDefault true;
      };

      services = {
        displayManager.defaultSession = "niri";
        displayManager.dms-greeter = {
          enable = true;
          compositor.name = "niri";
        };
        displayManager.sessionPackages = [ niriPkg ];
      };

      hardware.graphics.enable = mkDefault true;

      xdg.portal = {
        enable = true;
        extraPortals =
          [
            pkgs.xdg-desktop-portal-gtk
          ]
          ++ (
            if
              !niriPkg.cargoBuildNoDefaultFeatures
              || builtins.elem "xdp-gnome-screencast" niriPkg.cargoBuildFeatures
            then
              [ pkgs.xdg-desktop-portal-gnome ]
            else
              [ ]
          );
        configPackages = [ niriPkg pkgs.xdg-desktop-portal-gtk ];
      };

      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true;

      systemd.user.services.niri-flake-polkit = {
        description = "PolicyKit Authentication Agent provided by niri-flake";
        wantedBy = [ "niri.service" ];
        after = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };

      security.pam.services.swaylock = { };
      programs.dconf.enable = mkDefault true;
      fonts.enableDefaultPackages = mkDefault true;

      frgd.user.extraGroups = [ "video" ];
    })
  ];
}
