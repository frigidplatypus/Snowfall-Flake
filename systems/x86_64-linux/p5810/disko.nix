{
  disko.devices = {
    disk = {
      ata139273 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-ADATA_SU760_2L102LA8JKUW";
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
            root = {
              size = "100%";
              type = "8300";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [ "noatime" "nodiratime" ];
              };
            };
          };
        };
      };

      ata238655 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LH240HAHQ-00005_S45RNA0N238655";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zhome";
              };
            };
          };
        };
      };

      ata415399 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LH240HAHQ-00005_S45RNA0N415399";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zhome";
              };
            };
          };
        };
      };
    };
    zpool = {
# Home data pool mirrored across the two remaining disks for redundancy
      zhome = {
        type = "zpool";
        # Use mirror vdev of the two spare SATA/SSD devices (sdd and sde)
        mode = "mirror";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "true";
        };
        # Options for the zpool create command
        options = {
          ashift = "12";
        };
        mountpoint = null;

        datasets = {
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
          "home_justin/development" = {
            type = "zfs_fs";
            mountpoint = "/home/justin/development";
            options."com.sun:auto-snapshot" = "true";
          };
          "home_justin/notes" = {
            type = "zfs_fs";
            mountpoint = "/home/justin/notes";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
