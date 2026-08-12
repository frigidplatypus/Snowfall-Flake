{
  config,
  lib,
  pkgs,
  inputs,
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
      default = pkgs.niri;
      description = "The niri package to use.";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs.niri.enable = true;
      environment.systemPackages = with pkgs; [
        xdg-utils
        niriPkg
        inputs.noctalia.packages.${pkgs.system}.default
      ];

      programs.noctalia-greeter = {
        enable = true;
        greeter-args = "--session niri";
      };

      services.dbus.enable = true;

      environment.sessionVariables = {
        XCURSOR_THEME = "Capitaine Cursors (Gruvbox)";
        GTK_USE_PORTAL = "1";
        XDG_CURRENT_DESKTOP = "niri";
      };

      xdg = {
        autostart.enable = mkDefault true;
        menus.enable = mkDefault true;
        mime.enable = mkDefault true;
        icons.enable = mkDefault true;
      };

      services = {
        displayManager.defaultSession = "niri";
        displayManager.sessionPackages = [ niriPkg ];
      };

      hardware.graphics.enable = mkDefault true;

      xdg.portal = {
        enable = true;
        extraPortals = [
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
        configPackages = [
          niriPkg
          pkgs.xdg-desktop-portal-gtk
        ];
        config.common.default = "*";
      };

      security.polkit.enable = true;
      services.gnome.gnome-keyring.enable = true;

      systemd.user.services.niri-polkit = {
        description = "PolicyKit Authentication Agent for niri";
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
