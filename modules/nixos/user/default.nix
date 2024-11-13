{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.user;
in
#defaultIconFileName = "profile.png";
{
  options.frgd.user = with types; {
    name = mkOpt str "justin" "The name to use for the user account.";
    fullName = mkOpt str "Justin Martin" "The full name of the user.";
    email = mkOpt str "jus10mar10@gmail.com" "The email of the user.";
    initialPassword =
      mkOpt str "password"
        "The initial password to use when the user is first created.";
    # icon = mkOpt (nullOr package) defaultIcon
    #   "The profile picture to use for the user.";
    prompt-init = mkBoolOpt true "Whether or not to show an initial message when opening a new shell.";
    extraGroups = mkOpt (listOf str) [ ] "Groups for the user to be assigned.";
    extraOptions = mkOpt attrs { } (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  config = {
    environment.systemPackages = with pkgs; [ ];

    programs.fish = enabled;
    programs.starship = enabled;
    home-manager.backupFileExtension = "backuphm";

    frgd.home = {
      file = { };

      extraOptions = {
        home.shellAliases = {
          lc = "${pkgs.colorls}/bin/colorls --sd";
          lcg = "lc --gs";
          lcl = "lc -1";
          lclg = "lc -1 --gs";
          lcu = "${pkgs.colorls}/bin/colorls -U";
          lclu = "${pkgs.colorls}/bin/colorls -U -1";
        };
      };
    };

    users.users.${cfg.name} = {
      isNormalUser = true;
      inherit (cfg) name initialPassword;

      home = "/home/${cfg.name}";
      group = "users";

      shell = pkgs.fish;

      # Arbitrary user ID to use for the user. Since I only
      # have a single user on my machines this won't ever collide.
      # However, if you add multiple users you'll need to change this
      # so each user has their own unique uid (or leave it out for the
      # system to select).
      #uid = 1000;

      extraGroups = [ "wheel" ] ++ cfg.extraGroups;
    } // cfg.extraOptions;
  };
}
