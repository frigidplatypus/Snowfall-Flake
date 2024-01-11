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
    environment = mkIf cfg.virt-manager.enable {
      systemPackages = with pkgs;
        [
          # For lsusb
          virt-manager
        ];
    };
    frgd.user.extraGroups = [ "libvirt" ];
  };
}
