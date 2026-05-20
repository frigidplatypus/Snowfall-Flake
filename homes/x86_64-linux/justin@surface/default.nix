{
  lib,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
{
  programs.niri.settings = {
    input = {
      keyboard.xkb = {
        layout = "us";
        options = "caps:hyper";
      };
      touchpad = {
        tap-button-map = "left-right-middle";
        click-method = "clickfinger";
        dwt = true;
        natural-scroll = true;
      };
    };

    layout = {
      gaps = 6;
      center-focused-column = "never";
      default-column-width = {
        proportion = 2. / 3.;
      };
      focus-ring = {
        enable = false;
        width = 2;
        active.color = "#fe8019";
        inactive.color = "#504945";
        urgent.color = "#fb4934";
      };
      border = {
        enable = true;
        width = 2;
        active.color = "#fe8019ff";
        inactive.color = "#504945ff";
        urgent.color = "#fb4934ff";
      };
      preset-column-widths = [
        { proportion = 1. / 3.; }
        { proportion = 1. / 2.; }
        { proportion = 2. / 3.; }
      ];
    };

    hotkey-overlay.skip-at-startup = true;

    prefer-no-csd = true;

    window-rules = [
      {
        matches = [
          {
            app-id = "firefox$";
            title = "^Picture-in-Picture$";
          }
        ];
        open-floating = true;
      }
    ];

    spawn-at-startup = [
      {
        argv = [
          "${pkgs.foot}/bin/foot"
          "--server"
        ];
      }
      {
        argv = [
          "${pkgs._1password-gui}/bin/1password"
          "--silent"
        ];
      }
    ];

    binds = {
      "Print".action.screenshot = { };
      "Control+Print".action."screenshot-screen" = { };
      "Alt+Print".action."screenshot-window" = { };
      "Super+Return".action.spawn = [ "${pkgs.foot}/bin/footclient" ];
      "Super+Shift+Return".action.spawn = [ "${pkgs.firefox}/bin/firefox" ];
      "Super+E".action.spawn = [ "${pkgs.nautilus}/bin/nautilus" ];
      "Super+Space".action."spawn-sh" = "${pkgs.rofi}/bin/rofi -modi 'drun' -show drun";
      "Super+Shift+Q".action."close-window" = { };
      "Super+Shift+E".action."quit" = { };
      "Super+h".action."focus-column-left" = { };
      "Super+l".action."focus-column-right" = { };
      "Mod3+h".action."focus-column-left" = { };
      "Mod3+l".action."focus-column-right" = { };
      "Super+Up".action."focus-window-up" = { };
      "Super+Down".action."focus-window-down" = { };
      "Super+Shift+Left".action."move-column-left" = { };
      "Super+Shift+Right".action."move-column-right" = { };
      "Super+Shift+Up".action."move-window-up" = { };
      "Super+Shift+Down".action."move-window-down" = { };
      "Super+Ctrl+Left".action."set-column-width" = "-10%";
      "Super+Ctrl+Right".action."set-column-width" = "+10%";
      "Super+Ctrl+Up".action."set-window-height" = "+10%";
      "Super+Ctrl+Down".action."set-window-height" = "-10%";
      "Super+j".action."focus-workspace-down" = { };
      "Super+k".action."focus-workspace-up" = { };
      "Mod3+j".action."focus-workspace-down" = { };
      "Mod3+k".action."focus-workspace-up" = { };
      "Super+Alt+Shift+Right".action."move-column-to-workspace-down" = { };
      "Super+Alt+Shift+Left".action."move-column-to-workspace-up" = { };
      "Super+1".action."focus-workspace" = 1;
      "Super+2".action."focus-workspace" = 2;
      "Super+3".action."focus-workspace" = 3;
      "Super+4".action."focus-workspace" = 4;
      "Super+5".action."focus-workspace" = 5;
      "Super+6".action."focus-workspace" = 6;
      "Super+7".action."focus-workspace" = 7;
      "Super+8".action."focus-workspace" = 8;
      "Super+9".action."focus-workspace" = 9;
      "Super+0".action."focus-workspace" = 10;
      "Super+Shift+1".action."move-column-to-workspace" = 1;
      "Super+Shift+2".action."move-column-to-workspace" = 2;
      "Super+Shift+3".action."move-column-to-workspace" = 3;
      "Super+Shift+4".action."move-column-to-workspace" = 4;
      "Super+Shift+5".action."move-column-to-workspace" = 5;
      "Super+Shift+6".action."move-column-to-workspace" = 6;
      "Super+Shift+7".action."move-column-to-workspace" = 7;
      "Super+Shift+8".action."move-column-to-workspace" = 8;
      "Super+Shift+9".action."move-column-to-workspace" = 9;
      "Super+Shift+0".action."move-column-to-workspace" = 10;
      "Super+Shift+F".action."fullscreen-window" = { };
      "Super+F".action."maximize-column" = { };
      "Super+V".action."toggle-window-floating" = { };
      "Super+C".action."center-column" = { };
      "Super+Ctrl+C".action."center-visible-columns" = { };
      "Super+BracketLeft".action."consume-or-expel-window-left" = { };
      "Super+BracketRight".action."consume-or-expel-window-right" = { };
      "Super+Comma".action."consume-window-into-column" = { };
      "Super+Period".action."expel-window-from-column" = { };
      "Super+O".action."toggle-overview" = { };
      "Super+Shift+P".action."power-off-monitors" = { };
      "Super+r".action."switch-preset-column-width" = { };
      "Mod3+V".action.spawn = [
        "qs"
        "-c"
        "noctalia-shell"
        "ipc"
        "call"
        "launcher"
        "clipboard"
      ];
      "XF86AudioPlay".action.spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "play-pause"
      ];
      "XF86AudioNext".action.spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "next"
      ];
      "XF86AudioPrev".action.spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "previous"
      ];
      "XF86AudioStop".action.spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "stop"
      ];
      "XF86MonBrightnessUp".action."spawn-sh" =
        "current=$(dms brightness get backlight:intel_backlight | cut -d' ' -f2 | tr -d '%'); new=$((current + 10)); [ $new -gt 100 ] && new=100; dms brightness set backlight:intel_backlight $new";
      "XF86MonBrightnessDown".action."spawn-sh" =
        "current=$(dms brightness get backlight:intel_backlight | cut -d' ' -f2 | tr -d '%'); new=$((current - 10)); [ $new -lt 0 ] && new=0; dms brightness set backlight:intel_backlight $new";
      "XF86AudioRaiseVolume".action."spawn-sh" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
      "XF86AudioLowerVolume".action."spawn-sh" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
      "XF86AudioMute".action."spawn-sh" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };

    cursor = {
      theme = "Capitaine Cursors (Gruvbox)";
      size = 40;
    };

    environment = {
      XCURSOR_THEME = "Capitaine Cursors (Gruvbox)";
      XCURSOR_SIZE = "40";
      GTK_THEME = "Gruvbox-Plus-Dark";
      GTK_ICON_THEME = "Gruvbox-Plus-Dark";
      GTK_THEME_VARIANT = "dark";
      QT_QPA_PLATFORMTHEME = "gtk3";
      QT_STYLE_OVERRIDE = "gtk3";
      ADW_COLOR_SCHEME = "prefer-dark";
      XDG_CURRENT_DESKTOP = "niri";
    };
  };

  xdg.configFile = {
    niri-config.target = lib.mkForce "niri/hm.kdl";
    niri-config-dms = {
      target = "niri/config.kdl";
      text = builtins.concatStringsSep "\n" [
        ''include "hm.kdl"''
        ''include "dms/outputs.kdl"''
        ''include "dms/binds.kdl"''
        ''include "dms/windowrules.kdl"''
        ''include "dms/alttab.kdl"''
        ''include "dms/wpblur.kdl"''
        ''include "dms/colors.kdl"''
        ''include "dms/cursor.kdl"''
      ];
    };
  };

  sops.secrets.vikunja_api_key = { };
  sops.secrets.apple_app_password = { };
  # SOPS secrets for PIM calendar sync
  # sops.secrets.google_calendar_password = { };
  # sops.secrets.icloud_calendar_password = { };
  frgd = {
    suites.common = enabled;
    user = {
      enable = true;
      name = "justin";
    };

    desktop = {
      niri = enabled;
      addons.rofi = enabled;
    };
    apps = {
      # obsidian = enabled;
      # logseq = enabled;
      # kitty = enabled;
      # matrix_clients = enabled;
      ghostty = enabled;
      foot = enabled;
    };
    security = {
      sops = {
        enable = true;
        miniflux_config = enabled;
      };
    };
    cli-apps = {
      # pim = {
      #   enable = true;
      #   accounts = {
      #     gmail = {
      #       enable = true;
      #       email = "jus10mar10@gmail.com";
      #       primary = true;
      #       calendarColor = "light blue";
      #       # Only show these folders in aerc for a minimal list
      #       folders = "INBOX,Sent,Archive";
      #       syncMail = true;
      #       syncCalendar = false;
      #       syncContacts = false;
      #     };
      #     jk = {
      #       enable = true;
      #       email = "justin@justinandkathryn.com";
      #       calendarColor = "light green";
      #       folders = "INBOX,Sent,Archive";
      #       syncMail = true;
      #       syncCalendar = false;
      #       syncContacts = false;
      #     };
      #     icloud = {
      #       enable = true;
      #       primary = false;
      #       email = "jus10mar10@gmail.com";
      #       calendarColor = "yellow";
      #       syncMail = false;
      #       syncCalendar = true;
      #       syncContacts = true;
      #       appPasswordSecret = "apple_app_password";
      #       caldavUrl = "https://caldav.icloud.com/";
      #       carddavUrl = "https://contacts.icloud.com/";
      #       calendarUser = "jus10mar10@gmail.com";
      #       contactsUser = "jus10mar10@gmail.com";
      #       # Prefer the Martin Family Calendar as the primary collection
      #       # (discovered via `vdirsyncer discover`); also sync the other
      #       # Family collection UUID so both family calendars are available.
      #       primaryCollection = "5B01F554-FE12-4970-95F6-2F696FE78DE4";
      #       collections = [
      #         "93ecfb14-a475-4195-bec8-594e43e16837"
      #         "2896ed90-ccfb-4fff-8230-640843f10b70"
      #         "bca077e4f0da7a50c411c079c843d1d5826d2caf9667a2aed7d7ef9b3ca666bd"
      #         "home"
      #       ];
      #     };
      #   };
      #   contacts.enable = true;
      #   calendar = {
      #     enable = true;
      #     settings = {
      #       default = {
      #         default_calendar = "icloud";
      #       };
      #     };
      #   };
      # };
      neovim = enabled;
      home-manager = enabled;
      local-scripts = enabled;
      atuin = enabled;
      ranger = enabled;
      fish = enabled;
      # taskwarrior = {
      #   enable = true;
      #   taskpirate = {
      #     enable = true;
      #     hooksDir = "~/.local/share/task/hooks";
      #   };
      # };
      # matrix_clients = enabled;
      hass-cli = enabled;
      cliflux = enabled;
      yazi = enabled;
      # opencode = {
      #   enable = true;
      #   settings = {
      #     "$schema" = "https://opencode.ai/config.json";
      #     theme = "gruvbox";
      #     permission = {
      #       bash = {
      #         "git status" = "allow";
      #         "git diff" = "allow";
      #         "git log" = "allow";
      #         "git show" = "allow";
      #         "git branch" = "allow";
      #         "git add" = "ask";
      #         "git reset" = "ask";
      #         "git checkout" = "ask";
      #         "git commit" = "ask";
      #         "git commit *" = "ask";
      #         "git push" = "ask";
      #         "git push *" = "ask";
      #         pwd = "allow";
      #         ls = "allow";
      #         cat = "allow";
      #         head = "allow";
      #         tail = "allow";
      #         tree = "allow";
      #         rg = "allow";
      #         grep = "allow";
      #         find = "allow";
      #         "nix flake check" = "allow";
      #         "nix flake update" = "ask";
      #         "nix develop" = "allow";
      #         "nix search" = "allow";
      #         "nix shell" = "allow";
      #         treefmt = "allow";
      #         "nix build" = "ask";
      #         "nix run" = "ask";
      #         "nix *" = "ask";
      #         rm = "ask";
      #         "rm *" = "ask";
      #         mv = "ask";
      #         cp = "ask";
      #         mkdir = "ask";
      #         zfs = "ask";
      #         doas = "ask";
      #       };
      #     };
      #     command = {
      #       check = {
      #         template = "Run `nix flake check` to validate the flake and show any errors or warnings.";
      #         description = "Validate flake configuration";
      #       };
      #       format = {
      #         template = "Run `treefmt` to format all Nix files according to the project standards.";
      #         description = "Format Nix files";
      #       };
      #       build = {
      #         template = "Build the specified package using `nix build`. If no package is specified, build cliflux.";
      #         description = "Build Nix packages";
      #       };
      #       deploy = {
      #         template = "Deploy the NixOS configuration using `nixos-rebuild switch --flake .#<hostname>`. Ask which hostname to deploy if not specified.";
      #         description = "Deploy NixOS system";
      #       };
      #       update = {
      #         template = "Run `nix flake update` to update all flake inputs and show what changed.";
      #         description = "Update flake inputs";
      #       };
      #     };
      #   };
      # };
      # neomutt = enabled;
      # zellij = enabled;
    };
    services = {
      espanso = {
        enable = true;
        western_snippets = {
          enable = true;
        };
      };
    };
    tools = {
      git = {
        enable = true;
        internalGitKey = true;
      };
      direnv = enabled;
      misc = enabled;
      charms = enabled;
      ssh = enabled;
      nix-index = enabled;
    };
  };

  home.packages = with pkgs; [
    cfonts
    foot
    forgejo-cli
    frgd.numara
    heynote
    telegram-desktop
  ];

  # User-level aerc UI preferences: prefer inbox/sent/drafts/archive ordering
  # programs.aerc = {
  #   enable = true;
  #   extraConfig = {
  #     ui = {
  #       "folders-sort" = lib.mkForce "INBOX,Sent,Drafts,Archive,*";
  #     };
  #   };
  # };

  # Manage a minimal aerc accounts.conf directly so we control which
  # Do NOT manage accounts.conf here to avoid conflicts with the PIM module
  # which already generates account entries. If you want a fully-managed
  # accounts.conf, remove/adjust the generator in modules/home/cli-apps/pim.

  # If you want a minimal accounts.conf to be managed directly, add a
  # home.file entry here. By default the PIM module emits per-account
  # folders when configured and avoids conflicts with other modules.
}
