{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.archetypes.server;
in {
  options.frgd.archetypes.server = with types; {
    enable = mkBoolOpt false "Whether or not to enable the server archetype.";
  };

  config = mkIf cfg.enable {
    frgd = {
      suites = { common-slim = enabled; };

      cli-apps = {
        #        neovim = enabled;
        # tmux = enabled;
      };
    };
  };
}
