{
  lib,
  pkgs,
  modulesPath,
  ...
}:

# ── Obsidian App Container ───────────────────────────────────────────────────
#
# Incus container running Obsidian as a kiosk application, accessible via
# Guacamole (VNC) on p5810.
#
# Build and import:
#   nix build .#nixosConfigurations.obsidian.config.system.build.lxcMetadata \
#     --out-link ./result-meta
#   nix build .#nixosConfigurations.obsidian.config.system.build.tarball \
#     --out-link ./result-rootfs
#   incus image import \
#     ./result-meta/tarball/nixos-system-x86_64-linux.tar.xz \
#     ./result-rootfs/tarball/nixos-system-x86_64-linux.tar.xz \
#     --alias obsidian
#   incus init obsidian obsidian-app \
#     -c security.nesting=true \
#     -c limits.cpu=2 \
#     -c limits.memory=4GiB
#
# Mount the Obsidian vault from ZFS:
#   incus config device add obsidian-app vault disk \
#     source=/storage/obsidian \
#     path=/var/lib/kiosk/obsidian
#
#   incus start obsidian-app
#
# Then add to frgd.services.guacamole.connections on p5810:
#   obsidian = {
#     displayName = "Obsidian Notes";
#     hostname    = "obsidian.incus";   # or the container's bridge IP
#     port        = 5901;
#     width       = 1920;
#     height      = 1080;
#   };
# ────────────────────────────────────────────────────────────────────────────

with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/lxc-container.nix")
  ];

  # app-container archetype removed; this is now a standalone LXC container system.
  # To use native nixos-container instead, see p5810/default.nix for the new approach.
  # Leaving this config as-is for reference; update if building as native container.

  # frgd.archetypes.app-container = {
  #   enable = true;
  #
  #   app = {
  #     package = pkgs.obsidian;
  #     # Obsidian's main binary is "obsidian"; detected automatically via meta.mainProgram.
  #     # Pass --no-sandbox since the container has limited kernel capabilities.
  #     extraArgs = "--no-sandbox";
  #   };
  #
  #   display = {
  #     number = 1;
  #     width = 1920;
  #     height = 1080;
  #   };
  #
  #   vnc = {
  #     port = 5901; # must equal display.number + 5900
  #   };
  #
  #   # Obsidian doesn't need audio; enable if you add a plugin that uses it.
  #   audio.enable = false;
  # };

  # Get IP from LXD managed bridge dnsmasq (default profile uses lxdbr0).
  networking.useDHCP = mkForce true;

  # Allow the Nix sandbox to work inside the container (limited kernel caps).
  # The frgd.nix module sets system.stateVersion globally; not set here.
  nix.settings.sandbox = "relaxed";
}
