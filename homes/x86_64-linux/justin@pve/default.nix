{
  lib,
  pkgs,
  config,
  osConfig ? { },
  format ? "unknown",
  ...
}:
with lib;
with lib.frgd;
{
  home.stateVersion = "24.05";
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    cli-apps = {
      fish = enabled;
      neovim = enabled;
      home-manager = enabled;
    };

    tools = {
      git = enabled;
      misc = enabled;
    };
  };
}
