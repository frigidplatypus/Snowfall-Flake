{
  options,
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
{
  # imports = with inputs; [
  #   home-manager.nixosModules.home-manager
  # ];

  options.frgd.home = with types; {
    file = mkOpt attrs { } (mdDoc "A set of files to be managed by home-manager's `home.file`.");
    configFile = mkOpt attrs { } (
      mdDoc "A set of files to be managed by home-manager's `xdg.configFile`."
    );
    extraOptions = mkOpt attrs { } "Options to pass directly to home-manager.";
  };

  config = {
    frgd.home.extraOptions = {
      home.stateVersion = config.system.stateVersion;
      home.file = mkAliasDefinitions options.frgd.home.file;
      xdg.enable = true;
      xdg.configFile = mkAliasDefinitions options.frgd.home.configFile;
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backuphm";

      users.${config.frgd.user.name} = mkAliasDefinitions options.frgd.home.extraOptions;
    };
  };
}
