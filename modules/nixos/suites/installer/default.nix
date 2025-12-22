{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.suites.installer;
in
{
  options.frgd.suites.installer = with types; {
    enable = mkBoolOpt false "Whether or not to enable installer configuration.";
  };

  config = mkIf cfg.enable {
    # Packages available in the live installer environment
    environment.systemPackages = with pkgs; [
      fish
      frgd.neovim
      tmux
      disko
      nixos-anywhere

      # ZFS userland and streaming helpers
      zfs
      lzo
      lzop
      mbuffer
      pv

      # Git so the live image can fetch the latest Snowfall-Flake at boot
      git
    ];

    boot.supportedFilesystems = [ "zfs" ];
    networking.firewall.enable = false;
    services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
    services.getty.autologinUser = "justin";
    security.sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
    networking = {
      # networkmanager = enabled;
      wireless = enabled;
    };

    # Provide a hostId so ZFS can operate in the live environment
    networking.hostId = "00000000";

    frgd = {
      nix = enabled;

      system = {
        zfs = enabled;
      };

      services = {
        openssh = enabled;
        avahi = enabled;
      };

    };

    # Ensure the 'justin' user exists in the live environment with a home
    users.users.justin = {
      isNormalUser = true;
      description = "justin (live installer)";
      home = "/home/justin";
      createHome = true;
      extraGroups = [ "wheel" ];
    };

    # Try to auto-import ZFS root pools when booting the installer
    boot.zfs.forceImportRoot = false;

    # On first boot (after network-online) clone or update the Snowfall flake
    systemd.services.fetch-snowfall = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "runuser -l justin -c '${pkgs.git}/bin/git clone https://github.com/frigidplatypus/Snowfall-Flake ~/Snowfall-Flake || (cd ~/Snowfall-Flake && ${pkgs.git}/bin/git pull)'";
        RemainAfterExit = "yes";
      };
    };
  };
}
