{
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-NE-256_2242_0013956000560";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "550M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
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
        postCreateHook = "zfs snapshot zroot@blank";

        datasets = {
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };
          home_justin = {
            type = "zfs_fs";
            mountpoint = "/home/justin";
            options."com.sun:auto-snapshot" = "true";
          };
          "home_justin/flake" = {
            type = "zfs_fs";
            mountpoint = "/home/justin/flake";
            options."com.sun:auto-snapshot" = "true";
          };
          development = {
            type = "zfs_fs";
            mountpoint = "/home/justin/development";
            options."com.sun:auto-snapshot" = "true";
          };
          notes = {
            type = "zfs_fs";
            mountpoint = "/home/justin/notes";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
