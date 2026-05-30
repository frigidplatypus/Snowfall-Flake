{ lib, pkgs, config, modulesPath, inputs, ... }:
with lib;
with lib.frgd;
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # ---- Boot ----
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.zfs.forceImportRoot = true;

  # ---- Networking ----
  networking.hostName = "hermes";
  networking.useDHCP = true;
  networking.firewall.enable = false;

  # ---- User ----
  users.users.justin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key
    ];
  };
  security.sudo.wheelNeedsPassword = false;

  # ---- Hermes Agent ----
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
  };
  services.vscode-server.enable = true;

  # ---- Environment ----
  environment.systemPackages = with pkgs; [
    nixos-anywhere
    disko
    nixos-generators
    deploy-rs
    git
    gh
    curl
    jq
    neovim
  ];

  hardware.enableRedistributableFirmware = true;

  # ---- frgd modules ----
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--ssh"
      "--accept-dns"
    ];
  };

  frgd = {
    nix = enabled;
    security.sops = enabled;
    services = {
      openssh = enabled;
    };
    system.zfs = {
      enable = true;
      pools = [ "zroot" ];
    };
  };
}
