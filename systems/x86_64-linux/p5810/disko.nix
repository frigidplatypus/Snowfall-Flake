{
  disko.devices = {
    disk = {
      ata139273 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LH240HAHQ-00005_S45RNA0N139273";
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
      # Boot pool on the single NVMe/boot disk
      zroot = {
        type = "zpool";
        mountpoint = null;

        # ZFS properties applied to the pool root itself
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          xattr = "sa";
          acltype = "posixacl";
          atime = "off";
        };

        # Options for the zpool create command
        options = {
          ashift = "12";
        };

        datasets = {
          "ROOT/p5810" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              "com.sun:auto-snapshot" = "false";
            };
            postCreateHook = "sh -c 'zfs list -t snapshot zroot/ROOT/p5810@blank >/dev/null 2>&1 || zfs snapshot zroot/ROOT/p5810@blank'";
          };

          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options."com.sun:auto-snapshot" = "false";
          };

          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              "com.sun:auto-snapshot" = "false";
              compression = "zstd-1";
            };
          };

          "var/log" = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options = {
              "com.sun:auto-snapshot" = "false";
              recordsize = "128K";
            };
          };

          "var/lib" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options."com.sun:auto-snapshot" = "true";
          };

          "var/lib/containers" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/containers";
            options = {
              "com.sun:auto-snapshot" = "false";
              compression = "lz4";
            };
          };

          "var/lib/libvirt" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt";
            options = {
              "com.sun:auto-snapshot" = "true";
              compression = "lz4";
            };
          };
        };
      };

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
