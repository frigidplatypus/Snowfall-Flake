{
  lib,
  config,
  osConfig ? { },
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.apps._1password;
  # Check if the NixOS 1Password module is enabled
  nixos1PasswordEnabled = osConfig.frgd.apps._1password.enable or false;
in
{
  options.frgd.apps._1password = with types; {
    enable = mkBoolOpt nixos1PasswordEnabled "Whether or not to enable 1Password home configuration. Defaults to true if NixOS 1Password is enabled.";

    ssh-agent = {
      enable = mkBoolOpt true "Whether or not to use 1Password as SSH agent when 1Password is enabled.";
    };
  };

  config = mkIf cfg.enable {
    # Show a warning if home-manager 1Password is enabled but NixOS 1Password is not
    warnings =
      optional (!nixos1PasswordEnabled)
        "frgd.apps._1password is enabled in home-manager but frgd.apps._1password is not enabled in the NixOS configuration. 1Password may not work properly without the system-level configuration.";

    # Configure SSH to use 1Password agent if enabled
    programs.ssh = mkIf cfg.ssh-agent.enable {
      extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    };
  };
}
