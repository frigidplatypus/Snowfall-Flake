{ lib,config, ... }:
with lib;
with lib.frgd;
{
  sops.secrets.vikunja_api_key = { };
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common = enabled;
    desktop = {
      hyprland = enabled;
    };

    security = {
      sops = {
        enable = true;
        miniflux_config.enable = true;
      };
    };

    cli-apps = {
      taskwarrior = enabled;
      cliflux = enabled;
      tmux = enabled;
      local-scripts = enabled;
    };

    tools = {
      git = enabled;
      direnv = enabled;
      misc = enabled;
      charms = enabled;
    };
  };
}
