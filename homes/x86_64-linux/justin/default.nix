{
  lib,
  ...
}:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    cli-apps = {
      fish = enabled;
      neovim = enabled;
      home-manager = enabled;
      tmux = enabled;
      atuin = enabled;
      nushell = enabled;
    };

    tools = {
      git = enabled;
      misc = enabled;
    };
  };
}
