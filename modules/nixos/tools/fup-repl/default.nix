{ lib, pkgs, config, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.tools.fup-repl;
  fup-repl = pkgs.writeShellScriptBin "fup-repl" ''
    ${pkgs.fup-repl}/bin/repl ''${@}
  '';
in
{
  options.frgd.tools.fup-repl = with types; {
    enable = mkBoolOpt false "Whether to enable fup-repl or not";
  };

  config = mkIf cfg.enable { environment.systemPackages = [ fup-repl ]; };
}
