{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.frgd;
let
  cfg = config.frgd.nr;
in
{
  options.frgd.nr = with types; {
    command =
      mkOpt (enum [ "deploy" "build" "boot" "skip" ]) "deploy" ''
        How the `nr` deploy tool should treat this host.

        - `deploy` (default): run `nixos-rebuild switch` over SSH.
        - `build`: run `nixos-rebuild build` locally only — no SSH. Use for
          hosts the build machine cannot reach (e.g. remote desktops); the
          result is pulled from the `result` symlink afterwards.
        - `boot`: run `nixos-rebuild boot` over SSH — for hosts that cannot
          hot-swap and require a reboot.
        - `skip`: never touch this host. Replaces listing it in
          `EXCLUDED_HOSTS`.
      '';
  };
}
