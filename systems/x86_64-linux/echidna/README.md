# Echidna notes

## ZFS host ID
- The root pool `zroot` expects `networking.hostId = "34e78754"` (see `hardware.nix`).
- From a rescue shell, import the pool with an altroot and rebuild inside the chroot to update `/etc/hostid`:
  1. `zpool import -N -R /mnt zroot`
  2. `nixos-enter --root /mnt`
  3. Inside the chroot: ensure `networking.hostId` is set in the config and run `nixos-rebuild switch --flake .#echidna`. This writes `/etc/hostid` and refreshes the initrd so future boots import `zroot` automatically.
  4. Exit the chroot and `zpool export zroot` before rebooting.
- If the pool host ID ever drifts, export and re-import after the rebuild to record the updated ID on-disk.
