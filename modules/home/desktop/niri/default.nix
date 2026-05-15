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
  hyprlock-pkg = inputs.hyprlock.packages.${pkgs.system}.hyprlock;
  lock-cmd = "${hyprlock-pkg}/bin/hyprlock --immediate-render --no-fade-in";
in
{
  options.frgd.desktop.niri = with types; {
    enable = mkBoolOpt false "Whether or not to enable the niri home module.";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      brightnessctl
    ];

    services.swayidle = {
      enable = true;
      timeouts = [
        {
          timeout = 120;
          command = lock-cmd;
        }
        {
          timeout = 600;
          command = "niri msg action power-off-monitors";
          resumeCommand = "niri msg action power-on-monitors";
        }
        {
          timeout = 900;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
      events = {
        before-sleep = lock-cmd;
        lock = lock-cmd;
      };
    };

    frgd.desktop.addons = {
      hyprlock = enabled;
    };

  };
}
