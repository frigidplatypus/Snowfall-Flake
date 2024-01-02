{ options, config, pkgs, lib, ... }:
with lib;
with lib.frgd;
let cfg = config.frgd.system.boot;
in {
  options.frgd.system.boot = with types; {
    enable = mkBoolOpt false "Whether or not to enable booting.";
    grub = mkBoolOpt false "Enable grub";
    efi = mkBoolOpt false "Enable efi";
  };

  config = mkIf cfg.enable {
    boot.loader.grub = mkIf cfg.grub {
      enable = true;
      device = "/dev/sda";
      useOSProber = true;
    };
    boot.loader.systemd-boot = mkIf cfg.efi {
      enable = true;
      configurationLimit = 10;
      editor = true;
    };
    boot.loader.efi = mkIf cfg.efi {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };
}
