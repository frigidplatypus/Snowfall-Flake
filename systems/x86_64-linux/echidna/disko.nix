{
  disko.devices = {
    disk = {
      x = {
        type = "disk";
        device = "/dev/nvme0n1";
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
        # FIX: Set pool mountpoint to null for disko type checking
        mountpoint = null;

        # ZFS properties applied to the pool root itself
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          xattr = "sa"; # Extended attributes in inode
          acltype = "posixacl"; # Standard Linux ACLs
          atime = "off"; # Turn off access time logging
        };

        datasets = {
          # 1. Operating System Root (Ephemeral)
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              "com.sun:auto-snapshot" = "false";
            };
            postCreateHook = "zfs snapshot zroot/root@blank";
          };

          # 2. Nix Store (Tuned for small, read-heavy files)
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              "com.sun:auto-snapshot" = "false";
              atime = "off";
              recordsize = "64K";
            };
          };

          # 3. User Data (Persistent)
          home_justin = {
            type = "zfs_fs";
            mountpoint = "/home/justin";
            options."com.sun:auto-snapshot" = "true";
          };

          home_flake = {
            type = "zfs_fs";
            mountpoint = "/home/justin/flake";
            options."com.sun:auto-snapshot" = "true";
          };

          # 4. Project Data
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

          # 5. /var (System Volatile Data Container)
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              "com.sun:auto-snapshot" = "false";
              compression = "zstd-1"; # Faster compression for frequently written data
            };
          };

          # 6. /var/log (Logs)
          var_log = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options = {
              "com.sun:auto-snapshot" = "false";
              recordsize = "128K";
            };
          };

          # 7. /var/lib (Application State/Databases)
          var_lib = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
