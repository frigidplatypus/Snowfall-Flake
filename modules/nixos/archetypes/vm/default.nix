{
  config,
  lib,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.archetypes.vm;
in
{
  options.frgd.archetypes.vm = with types; {
    enable = mkBoolOpt false "Whether or not to enable the virtual machine archetype.";
  };

  config = mkIf cfg.enable {
    services.getty.autologinUser = "root";
    services.qemuGuest = enabled;
    frgd = {
      nix = enabled;

      cli-apps = {
        nh = enabled;
      };
      services = {
        openssh = enabled;
        tailscale = enabled;
      };
      security = {
        sops = enabled;
        doas = enabled;
      };
      system = {
        boot = {
          enable = true;
          efi = true;
        };
        locale = enabled;
        time = enabled;
        xkb = enabled;
      };
    };
  };
}
