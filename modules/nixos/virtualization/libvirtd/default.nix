{ options, config, lib, pkgs, ... }:

with lib;
with lib.frgd;
let cfg = config.frgd.virtualization.libvirtd;
in {
  options.frgd.virtualization.libvirtd = with types; {
    enable = mkBoolOpt false "Whether or not to enable libvirtd";
    virt-manager = {
      enable = mkBoolOpt false "Whether or not to enable Virt-Manager";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu.ovmf = enabled;
    };
    environment.systemPackages = with pkgs;
      [
        # For lsusb
        usbutils
      ];
    frgd.user.extraGroups = [ "libvirt" ];
    programs.virt-manager = mkIf cfg.virt-manager.enable { enable = true; };

  };
}
