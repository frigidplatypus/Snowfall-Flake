{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
let
  inherit (lib)
    types
    mkIf
    mkDefault
    mkMerge
    ;
  inherit (lib.frgd) mkOpt;

  cfg = config.frgd.user;

  is-linux = pkgs.stdenv.isLinux;
  is-darwin = pkgs.stdenv.isDarwin;

  home-directory =
    if cfg.name == null then
      null
    else if is-darwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{
  options.frgd.user = {
    enable = mkOpt types.bool false "Whether to configure the user account.";
    name = mkOpt (types.nullOr types.str) config.frgd.user.name "The user account.";

    fullName = mkOpt types.str "Justin Martin" "The full name of the user.";
    email = mkOpt types.str "jus10mar10@gmail.com" "The email of the user.";

    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "frgd.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "frgd.user.home must be set";
        }
      ];

      home = {
        username = mkDefault cfg.name;
        homeDirectory = mkDefault cfg.home;
        sessionVariables = {
          EDITOR = "nvim";
        };
        file.".nix-colors.html".text =
          # HTML
          ''
            <html>
              <style>
                .color-container {
                height: 200px;
                width: 25%;
                float:left;
                box-size: border-box;
                }
                .light-text {
                color: #${colorScheme.palette.base07};
                }
                .medium-text{
                color: #${colorScheme.palette.base03};
                }
                .dark-text {
                color: #${colorScheme.palette.base00};
                }
              </style>
              <div style="width:100%; text-align:center; margin: 0px">
                <h1>${colorScheme.name}</h1>
                <h2>${colorScheme.slug}</h2>
                <div class="color-container" style="background-color:#${colorScheme.palette.base00}; ">
                  <p>base00</p>
                  <p>${colorScheme.palette.base00}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container"style="background-color:#${colorScheme.palette.base01}; ">
                  <p>base01</p>
                  <p>${colorScheme.palette.base01}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base02}; ">
                  <p>base02</p>
                  <p>${colorScheme.palette.base02}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base03}; ">
                  <p>base03</p>
                  <p>${colorScheme.palette.base03}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base04}; ">
                  <p>base04</p>
                  <p>${colorScheme.palette.base04}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base05}; ">
                  <p>base05</p>
                  <p>${colorScheme.palette.base05}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base06}; ">
                  <p>base06</p>
                  <p>${colorScheme.palette.base06}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base07}; ">
                  <p>base07</p>
                  <p>${colorScheme.palette.base07}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base08}; ">
                  <p>base08</p>
                  <p>${colorScheme.palette.base08}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base09}; ">
                  <p>base09</p>
                  <p>${colorScheme.palette.base09}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base0A}; ">
                  <p>base0A</p>
                  <p>${colorScheme.palette.base0A}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base0B}; ">
                  <p>base0B</p>
                  <p>${colorScheme.palette.base0B}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base0C}; ">
                  <p>base0C</p>
                  <p>${colorScheme.palette.base0C}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base0D}; ">
                  <p>base0D</p>
                  <p>${colorScheme.palette.base0D}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base0E}; ">
                  <p>base0E</p>
                  <p>${colorScheme.palette.base0E}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
                <div class="color-container" style="background-color:#${colorScheme.palette.base0F}; ">
                  <p>base0F</p>
                  <p>${colorScheme.palette.base0F}</p>
                  <p class="light-text">light-text</p>
                  <p class="medium-text">medium-text</p>
                  <p class="dark-text">dark-text</p>
                </div>
              </div>
            </html>
          '';
      };
      # frgd = {
      #   tools.lsd = enabled;
      #   cli-apps = {
      #     zoxide = enabled;
      #     neovim = enabled;
      #     home-manager = enabled;
      #     ranger = enabled;
      #     fish = enabled;
      #   };
      #
      #   tools = {
      #     git = enabled;
      #     direnv = enabled;
      #     misc = enabled;
      #     charms = enabled;
      #     ssh = enabled;
      #   };
      # };
    }
  ]);
}
