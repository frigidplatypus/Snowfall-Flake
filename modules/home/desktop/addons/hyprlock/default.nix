{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.desktop.addons.hyprlock;
    # Define the battery script as a Nix derivation
    hyprlockBatteryScript = pkgs.writeShellScriptBin "hyprlock-battery-status" ''
    #!/bin/bash

    # Path to your battery (adjust if needed, e.g., BAT1)
    BATTERY_PATH="/sys/class/power_supply/BAT0"

    # Check if battery path exists
    if [ ! -d "$BATTERY_PATH" ]; then
        echo " No Battery Found" # Or another suitable 'no battery' icon like \uf05e (fa-ban)
        exit 0
    fi

    CAPACITY=$(cat "$BATTERY_PATH/capacity")
    STATUS=$(cat "$BATTERY_PATH/status")

    ICON=""
    if [ "$STATUS" = "Charging" ]; then
        # Font Awesome 'fa-bolt' icon (⚡)
        ICON=""
    elif [ "$STATUS" = "Full" ]; then
        # Font Awesome 'fa-battery-full' icon (100%)
        ICON=""
    else # Discharging or Unknown status
        if (( CAPACITY > 90 )); then ICON=" "; # fa-battery-full
        elif (( CAPACITY > 75 )); then ICON=" "; # fa-battery-three-quarters
        elif (( CAPACITY > 50 )); then ICON=" "; # fa-battery-half
        elif (( CAPACITY > 25 )); then ICON=" "; # fa-battery-quarter
        else ICON=" "; # fa-battery-empty
        fi
    fi

    # Using 'printf' to ensure no trailing newline, which can affect label positioning
    printf "%s %s%%\n" "$ICON" "$CAPACITY"
  '';
in
{
  options.frgd.desktop.addons.hyprlock = with types; {
    enable = mkBoolOpt false "Whether or not to enable hyprlock.";
  };

  config = mkIf cfg.enable {

    programs.hyprlock = {
      enable = true;
      package = inputs.hyprlock.packages.${pkgs.system}.hyprlock;
      settings = {
        general = {
          hide_cursor = true;
          ignore_empty_input = true;
        };
        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];
        label = [
          # Clock label
          {
            monitor = ""; # Empty string means all monitors
            # text = "cmd[update:1000] date \"+%H:%M\""; # Update every 1 second
            text = "$TIME12"; # Use Hyprland's built-in time variable
            color = "rgb(${colorScheme.palette.base07})"; # White
            font_size = 120;
            font_family = "${font}"; # Ensure this font is available on your system
            position = "0,200"; # Adjust X, Y position
            # halign = "center";
            # valign = "bottom";
          }
          # Battery label (now uses Nerd Font icons from the script)
          {
            monitor = "";
            text = "cmd[update:5000] ${hyprlockBatteryScript}/bin/hyprlock-battery-status";
            color = "rgb(${colorScheme.palette.base07})";
            font_size = 24;
            # IMPORTANT: This font_family MUST be a Nerd Font for the icons to render!
            font_family = "${font-mono}"; # Or a specific Nerd Font like "Symbols Nerd Font Mono" or "JetBrainsMono Nerd Font"
            # halign = "center";
            valign = "bottom";
          }
        ];

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(${colorScheme.palette.base0A})";
            inner_color = "rgb(${colorScheme.palette.base03})";
            outer_color = "rgb(${colorScheme.palette.base09})";
            capslock_color = "rgb(${colorScheme.palette.base0F})";
            fail_color = "rgb(${colorScheme.palette.base08})";
            hide_input_base_color = "rgb(${colorScheme.palette.base0B})";
            fail_text = "Wrong Password";
            outline_thickness = 5;
            shadow_passes = 2;
            hide_input = true;
          }
        ];

      };
    };
  };
}
