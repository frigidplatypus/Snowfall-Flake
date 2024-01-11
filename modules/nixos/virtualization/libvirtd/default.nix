{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.virtualization.libvirtd;
in {
  options.frgd.virtualization.libvirtd = with types; {
    enable = mkBoolOpt false "Whether or not to enable libvirtd";
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemuOvmf = true;
    };
    environment.systemPackages = with pkgs;
      [
        # For lsusb
        usbutils
      ];
    frgd.user.extraGroups = [ "libvirt" ];
  };
}
