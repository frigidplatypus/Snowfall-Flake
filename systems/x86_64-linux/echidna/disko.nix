{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.000000000000000100a07520265a0347";
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
        mountpoint = null;

        # ZFS properties applied to the pool root itself
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          xattr = "sa"; # Extended attributes in inode
          acltype = "posixacl"; # Standard Linux ACLs
          atime = "off"; # Turn off access time logging
        };

        # Options for the zpool create command
        options = {
          # Set ashift to 12 for 4k block size, optimal for modern SSDs.
          ashift = "12";
        };

        datasets = {
          # 1. Operating System Root (Ephemeral)
          "ROOT/echidna" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              "com.sun:auto-snapshot" = "false";
            };
            postCreateHook = "zfs snapshot zroot/ROOT/echidna@blank";
          };

          # 2. Nix Store (Tuned for small, read-heavy files)
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              "com.sun:auto-snapshot" = "false";
              atime = "off";
              # Use 16K recordsize for better performance with many small files.
              recordsize = "16K";
            };
          };

          # 3. User Data (Persistent)
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

          # 5. /var (System Volatile Data Container)
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              "com.sun:auto-snapshot" = "false";
              compression = "zstd-1"; # Faster compression for frequently written data
            };
          };
          "var/log" = {
            # This will create zroot/var/log
            type = "zfs_fs";
            mountpoint = "/var/log";
            options = {
              "com.sun:auto-snapshot" = "false";
              recordsize = "128K";
            };
          };
          "var/lib" = {
            # This will create zroot/var/lib
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
