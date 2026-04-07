{
  lib,
  config,
  options,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.beszel-agent;
in
{
  options.frgd.services.beszel-agent = with types; {
    enable = mkBoolOpt false "Whether or not to enable beszel-agent.";
  };

  config = mkIf cfg.enable {

    services.beszel.agent = {
      enable = true;
      environmentFile = config.sops.secrets.beszel_env.path;
    };

    sops.secrets.beszel_env = {
      owner = "beszel-agent";
      mode = "0640";
    };

  };
}
