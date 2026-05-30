# ZFS on root - single disk
# Update the device path to match your actual disk before install.
# Use `lsblk -o NAME,ID-LINK,SIZE,MODEL` to find the correct by-id path.
{ lib, ... }:
let
  # TODO: Replace with actual disk by-id path
  diskDevice = "/dev/disk/by-id/wwn-XXXXXX";
in
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = diskDevice;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
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
    zpool = {
      zroot = {
        type = "zpool";
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
          "var_lib" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options."com.sun:auto-snapshot" = "true";
          };
          "var_lib_hermes" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/hermes";
            options."com.sun:auto-snapshot" = "true";
          };
          log = {
            type = "zfs_fs";
            mountpoint = "/var/log";
            options."com.sun:auto-snapshot" = "false";
          };
        };
      };
    };
  };
}
