{
  lib,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
{

  wayland.windowManager.niri.settings = {
    input = {
      keyboard.xkb = {
        layout = "us";
        options = "caps:hyper";
      };
      touchpad = {
        # tap-button-map = "left-right-middle";
        click-method = "clickfinger";
        dwt = { };
        natural-scroll = { };
      };
    };

    layout = {
      gaps = 6;
      center-focused-column = "never";
      default-column-width = {
        proportion = 2. / 3.;
      };
      focus-ring = {
        width = 2;
        active-color = "#fe8019";
        inactive-color = "#504945";
        urgent-color = "#fb4934";
      };
      border = {
        width = 2;
        active-color = "#fe8019ff";
        inactive-color = "#504945ff";
        urgent-color = "#fb4934ff";
      };
      preset-column-widths._children = [
        { proportion = 1. / 3.; }
        { proportion = 1. / 2.; }
        { proportion = 2. / 3.; }
      ];
    };

    hotkey-overlay.skip-at-startup = true;

    prefer-no-csd = { };

    _children = [
      {
        spawn-at-startup._args = [
          "${pkgs.foot}/bin/foot"
          "--server"
        ];
      }
      {
        spawn-at-startup._args = [
          "${pkgs._1password-gui}/bin/1password"
          "--silent"
        ];
      }
      {
        window-rule._children = [
          {
            match._props = {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
            };
          }
          { open-floating = true; }
        ];
      }
    ];

    binds = {
      "Print".screenshot = { };
      "Control+Print"."screenshot-screen" = { };
      "Alt+Print"."screenshot-window" = { };
      "Super+Return".spawn = [ "${pkgs.foot}/bin/footclient" ];
      "Super+Shift+Return".spawn = [ "${pkgs.firefox}/bin/firefox" ];
      "Super+E".spawn = [ "${pkgs.nautilus}/bin/nautilus" ];
      "Super+Space"."spawn-sh" = "${pkgs.rofi}/bin/rofi -modi 'drun' -show drun";
      "Super+Shift+Q"."close-window" = { };
      "Super+Shift+E"."quit" = { };
      "Super+h"."focus-column-left" = { };
      "Super+l"."focus-column-right" = { };
      "Mod3+h"."focus-column-left" = { };
      "Mod3+l"."focus-column-right" = { };
      "Super+Up"."focus-window-up" = { };
      "Super+Down"."focus-window-down" = { };
      "Super+Shift+Left"."move-column-left" = { };
      "Super+Shift+Right"."move-column-right" = { };
      "Super+Shift+Up"."move-window-up" = { };
      "Super+Shift+Down"."move-window-down" = { };
      "Super+Ctrl+Left"."set-column-width" = "-10%";
      "Super+Ctrl+Right"."set-column-width" = "+10%";
      "Super+Ctrl+Up"."set-window-height" = "+10%";
      "Super+Ctrl+Down"."set-window-height" = "-10%";
      "Super+j"."focus-workspace-down" = { };
      "Super+k"."focus-workspace-up" = { };
      "Mod3+j"."focus-workspace-down" = { };
      "Mod3+k"."focus-workspace-up" = { };
      "Super+Alt+Shift+Right"."move-column-to-workspace-down" = { };
      "Super+Alt+Shift+Left"."move-column-to-workspace-up" = { };
      "Super+1"."focus-workspace" = 1;
      "Super+2"."focus-workspace" = 2;
      "Super+3"."focus-workspace" = 3;
      "Super+4"."focus-workspace" = 4;
      "Super+5"."focus-workspace" = 5;
      "Super+6"."focus-workspace" = 6;
      "Super+7"."focus-workspace" = 7;
      "Super+8"."focus-workspace" = 8;
      "Super+9"."focus-workspace" = 9;
      "Super+0"."focus-workspace" = 10;
      "Super+Shift+1"."move-column-to-workspace" = 1;
      "Super+Shift+2"."move-column-to-workspace" = 2;
      "Super+Shift+3"."move-column-to-workspace" = 3;
      "Super+Shift+4"."move-column-to-workspace" = 4;
      "Super+Shift+5"."move-column-to-workspace" = 5;
      "Super+Shift+6"."move-column-to-workspace" = 6;
      "Super+Shift+7"."move-column-to-workspace" = 7;
      "Super+Shift+8"."move-column-to-workspace" = 8;
      "Super+Shift+9"."move-column-to-workspace" = 9;
      "Super+Shift+0"."move-column-to-workspace" = 10;
      "Super+Shift+F"."fullscreen-window" = { };
      "Super+F"."maximize-column" = { };
      "Super+V"."toggle-window-floating" = { };
      "Super+C"."center-column" = { };
      "Super+Ctrl+C"."center-visible-columns" = { };
      "Super+BracketLeft"."consume-or-expel-window-left" = { };
      "Super+BracketRight"."consume-or-expel-window-right" = { };
      "Super+Comma"."consume-window-into-column" = { };
      "Super+Period"."expel-window-from-column" = { };
      "Super+O"."toggle-overview" = { };
      "Super+Shift+P"."power-off-monitors" = { };
      "Super+r"."switch-preset-column-width" = { };
      "XF86AudioPlay".spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "play-pause"
      ];
      "XF86AudioNext".spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "next"
      ];
      "XF86AudioPrev".spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "previous"
      ];
      "XF86AudioStop".spawn = [
        "${pkgs.playerctl}/bin/playerctl"
        "stop"
      ];
      "XF86MonBrightnessUp"."spawn-sh" = "${pkgs.brightnessctl}/bin/brightnessctl set +10%";
      "XF86MonBrightnessDown"."spawn-sh" = "${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
      "XF86AudioRaiseVolume"."spawn-sh" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
      "XF86AudioLowerVolume"."spawn-sh" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
      "XF86AudioMute"."spawn-sh" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
    };

    cursor = {
      xcursor-theme = "Capitaine Cursors (Gruvbox)";
      xcursor-size = 40;
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

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
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
      obsidian = enabled;
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
    spec-kit
    gparted
    kdePackages.partitionmanager
    gnome-disk-utility
    blivet-gui
    brightnessctl
    cfonts
    exfatprogs
    fatresize
    foot
    forgejo-cli
    frgd.numara
    heynote
    parted
    polkit
    telegram-desktop
    util-linux
    dosfstools
    e2fsprogs
    ffmpeg
    yt-dlp
    udiskie
    frgd.sb
  ];

  programs.outl = {
    enable = true;
    installDesktop = true;
  };

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
