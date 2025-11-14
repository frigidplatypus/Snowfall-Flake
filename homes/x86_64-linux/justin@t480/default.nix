{
  lib,
  config,
  pkgs,
  osConfig ? { },
  format ? "unknown",
  ...
}:
with lib;
with lib.frgd;
{
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
    home = {
      extraOptions = {
        home.stateVersion = "24.11";
      };
    };
    desktop = {
      hyprland = {
        enable = true;
        extra-config = {
          monitor = "eDP-1, 1920x1080, 0x0, 1";
        };
      };
    };
    apps = {
      obsidian = enabled;
      kitty = enabled;
      matrix_clients = enabled;
      ghostty = enabled;
    };
    security = {
      sops = {
        enable = true;
        miniflux_config = enabled;
      };
    };
    cli-apps = {
      pim = {
        enable = true;
        accounts = {
          gmail = {
            enable = true;
            email = "jus10mar10@gmail.com";
            primary = true;
            calendarColor = "light blue";
            # Only show these folders in aerc for a minimal list
            folders = "INBOX,Sent,Archive";
            syncMail = true;
            syncCalendar = false;
            syncContacts = false;
          };
          jk = {
            enable = true;
            email = "justin@justinandkathryn.com";
            calendarColor = "light green";
            folders = "INBOX,Sent,Archive";
            syncMail = true;
            syncCalendar = false;
            syncContacts = false;
          };
          icloud = {
            enable = true;
            primary = false;
            email = "jus10mar10@gmail.com";
            calendarColor = "yellow";
            syncMail = false;
            syncCalendar = true;
            syncContacts = true;
            appPasswordSecret = "apple_app_password";
            caldavUrl = "https://caldav.icloud.com/";
            carddavUrl = "https://contacts.icloud.com/";
            calendarUser = "jus10mar10@gmail.com";
            contactsUser = "jus10mar10@gmail.com";
            # Prefer the Martin Family Calendar as the primary collection
            # (discovered via `vdirsyncer discover`); also sync the other
            # Family collection UUID so both family calendars are available.
            primaryCollection = "5B01F554-FE12-4970-95F6-2F696FE78DE4";
            collections = [
              "93ecfb14-a475-4195-bec8-594e43e16837"
              "2896ed90-ccfb-4fff-8230-640843f10b70"
              "bca077e4f0da7a50c411c079c843d1d5826d2caf9667a2aed7d7ef9b3ca666bd"
              "home"
            ];
          };
        };
        contacts.enable = true;
        calendar = {
          enable = true;
          settings = {
            default = {
              default_calendar = "icloud";
            };
          };
        };
      };
      neovim = enabled;
      home-manager = enabled;
      local-scripts = enabled;
      atuin = disabled;
      ranger = enabled;
      fish = enabled;
      taskwarrior = {
        enable = true;
        taskpirate = {
          enable = true;
          hooksDir = "~/.local/share/task/hooks";
        };
      };
      matrix_clients = enabled;
      hass-cli = enabled;
      cliflux = enabled;
      yazi = enabled;
      opencode = {
        enable = true;
        settings = {
          "$schema" = "https://opencode.ai/config.json";
          theme = "gruvbox";
          permission = {
            bash = {
              "git status" = "allow";
              "git diff" = "allow";
              "git log" = "allow";
              "git show" = "allow";
              "git branch" = "allow";
              "git add" = "ask";
              "git reset" = "ask";
              "git checkout" = "ask";
              "git commit" = "ask";
              "git commit *" = "ask";
              "git push" = "ask";
              "git push *" = "ask";
              pwd = "allow";
              ls = "allow";
              cat = "allow";
              head = "allow";
              tail = "allow";
              tree = "allow";
              rg = "allow";
              grep = "allow";
              find = "allow";
              "nix flake check" = "allow";
              "nix flake update" = "ask";
              "nix develop" = "allow";
              "nix search" = "allow";
              "nix shell" = "allow";
              treefmt = "allow";
              "nix build" = "ask";
              "nix run" = "ask";
              "nix *" = "ask";
              rm = "ask";
              "rm *" = "ask";
              mv = "ask";
              cp = "ask";
              mkdir = "ask";
            };
          };
          command = {
            check = {
              template = "Run `nix flake check` to validate the flake and show any errors or warnings.";
              description = "Validate flake configuration";
            };
            format = {
              template = "Run `treefmt` to format all Nix files according to the project standards.";
              description = "Format Nix files";
            };
            build = {
              template = "Build the specified package using `nix build`. If no package is specified, build cliflux.";
              description = "Build Nix packages";
            };
            deploy = {
              template = "Deploy the NixOS configuration using `nixos-rebuild switch --flake .#<hostname>`. Ask which hostname to deploy if not specified.";
              description = "Deploy NixOS system";
            };
            update = {
              template = "Run `nix flake update` to update all flake inputs and show what changed.";
              description = "Update flake inputs";
            };
          };
          formatter = {
            nix = "nixfmt";
            "*.md" = "prettier";
          };
          webfetch = "allow";
        };
      };
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
      git = enabled;
      direnv = enabled;
      misc = enabled;
      charms = enabled;
      ssh = enabled;
      nix-index = enabled;
    };
  };

  home.packages = with pkgs; [ cfonts ];

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
