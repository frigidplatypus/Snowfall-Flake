{
  options,
  config,
  pkgs,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.node;
in
{
  options.frgd.tools.node = with types; {
    enable = mkBoolOpt false "Whether or not to install NodeJS and related tools.";
    pkg = mkOpt package pkgs.nodejs_22 "The NodeJS package to use";
    prettier = {
      enable = mkBoolOpt false "Whether or not to install Prettier";
      pkg = mkOpt package pkgs.prettier "The Prettier package to use";
    };
    yarn = {
      enable = mkBoolOpt false "Whether or not to install Yarn";
      pkg = mkOpt package pkgs.yarn "The Yarn package to use";
    };
    pnpm = {
      enable = mkBoolOpt false "Whether or not to install Pnpm";
      pkg = mkOpt package pkgs.pnpm "The Pnpm package to use";
    };
    flyctl = {
      enable = mkBoolOpt false "Whether or not to install flyctl";
      pkg = mkOpt package pkgs.flyctl "The flyctl package to use";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      with pkgs;
      [ cfg.pkg ]
      ++ (lib.optional cfg.prettier.enable cfg.prettier.pkg)
      ++ (lib.optional cfg.yarn.enable cfg.yarn.pkg)
      ++ (lib.optional cfg.pnpm.enable cfg.pnpm.pkg)
      ++ (lib.optional cfg.flyctl.enable cfg.flyctl.pkg);
  };
}
