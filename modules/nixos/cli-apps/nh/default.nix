inputs@{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.cli-apps.nh;
in
{
  options.frgd.cli-apps.nh = with types; {
    enable = mkBoolOpt false "Whether or not to enable nh.";
    flakePath = mkOption {
      type = str;
      default = "/home/justin/flake";
      description = "Path to the Nix flake to be used by nh.";
    };
  };

  config = mkIf cfg.enable {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = cfg.flakePath;
    };
  };
}
