{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.system.home-wifi;
in
{
  options.frgd.system.home-wifi = with types; {
    enable = mkBoolOpt false "Whether or not to manage home-wifi settings.";
  };

  config = mkIf cfg.enable {

    sops.secrets.wireless_env = { };
    # Use the new secrets handling introduced by wpa_supplicant/NixOS.
    # `secretsFile` replaces the deprecated `environmentFile` option.
    networking.wireless.secretsFile = config.sops.secrets.wireless_env.path;
    networking.wireless.networks = {
      # Move from `psk = "@PSK_...@"` to `pskRaw = "ext:KEY"`.
      # The KEY must exist inside the secrets file referenced by
      # `sops.secrets.wireless_env.path` and be in plain key=value format.
      # Your current wireless_env contains:
      #   PSK_MAR10=redacted
      #   PSK_Martins-5=redacted!
      #   PSK_CBCoffice=redacted
      #   PSK_WesternDevices=redacted
      # Map those to networks below. Note that attribute names with
      # characters invalid in Nix identifiers (e.g. hyphen) must be quoted.
      Mar10.pskRaw = "ext:PSK_MAR10";
      "Martins-5".pskRaw = "ext:PSK_Martins-5";
      CBCoffice.pskRaw = "ext:PSK_CBCoffice";
      "Western Devices".pskRaw = "ext:PSK_WesternDevices";
    };
    environment.systemPackages = [
      inputs.wifitui.packages.${pkgs.system}.default
    ];

  };
}
