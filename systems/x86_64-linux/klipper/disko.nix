{
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ACJC2M064HS_985110500063";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "550M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        # mode = "single";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";

        datasets = {
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          home_justin = {
            type = "zfs_fs";
            mountpoint = "/home/justin";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
