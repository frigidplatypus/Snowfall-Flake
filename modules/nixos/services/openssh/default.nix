{ options, config, pkgs, lib, host ? "", format ? "", inputs ? { }, ... }:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.openssh;

  user = config.users.users.${config.frgd.user.name};
  user-id = builtins.toString user.uid;

  # @TODO(jakehamilton): This is a hold-over from an earlier Snowfall Lib version which used
  # the specialArg `name` to provide the host name.
  name = host;

  default-key =
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIj24tr9NcCrRVFSj1Nk2DSx3gFWHxAWIV36EBh6UDWFtZLtTCDYTDvk/z0okL3Dkhjf2VIIkHuWTCHz7KGKJcxvM+pjdxFl/rLocMOkGn2uIWRbgk+yHnc62ARosy/VQ1UcHswTman8KdlSRU2qjuK3etP26JsKsUhd+/qXr+HSTlcJFrZH+YOVar/K3HklCxOrSXnNSLmJEvbC7s12EgQYiP1J2KLP18LsXmB6aNwpvendeooDZpDayrJ7qxuYJhSjzHTmLoNBxxDe1IuFlH4HdwtnrNI++v4tzfKNA3FnQ6r1CRLtNjrkIjDylI8GrfMr8rLDCEcUUzsXqnuhiMLmQwFNVCfFCmU02G60uuEpZlwxGGrZRCT6MQWu9NRlwIpZ9b/DvAmcBj71CuBtAoZSulVQ1KytvV+vuTp80s04n+YQJTxDLvPoJMXUJ+sTQieib8IfOzwVCNmx98pBvxr71XGEwpPWX2SViD8DYfzND8NLo4eq0WF2eXFBY3p3U= justin@nixos";

  other-hosts = lib.filterAttrs
    (key: host:
      key != name && (host.config.frgd.user.name or null) != null)
    ((inputs.self.nixosConfigurations or { }) // (inputs.self.darwinConfigurations or { }));

  other-hosts-config = lib.concatMapStringsSep
    "\n"
    (name:
      let
        remote = other-hosts.${name};
        remote-user-name = remote.config.frgd.user.name;
        remote-user-id = builtins.toString remote.config.users.users.${remote-user-name}.uid;

        forward-gpg = optionalString (config.programs.gnupg.agent.enable && remote.config.programs.gnupg.agent.enable)
          ''
            RemoteForward /run/user/${remote-user-id}/gnupg/S.gpg-agent /run/user/${user-id}/gnupg/S.gpg-agent.extra
            RemoteForward /run/user/${remote-user-id}/gnupg/S.gpg-agent.ssh /run/user/${user-id}/gnupg/S.gpg-agent.ssh
          '';

      in
      ''
        Host ${name}
          User ${remote-user-name}
          ForwardAgent yes
          Port ${builtins.toString cfg.port}
          ${forward-gpg}
      ''
    )
    (builtins.attrNames other-hosts);
in
{
  options.frgd.services.openssh = with types; {
    enable = mkBoolOpt false "Whether or not to configure OpenSSH support.";
    authorizedKeys =
      mkOpt (listOf str) [ default-key ] "The public keys to apply.";
    port = mkOpt port 2222 "The port to listen on (in addition to 22).";
    manage-other-hosts = mkOpt bool true "Whether or not to add other host configurations to SSH config.";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;

      settings = {
        PermitRootLogin = if format == "install-iso" then "yes" else "no";
        PasswordAuthentication = false;
      };

      extraConfig = ''
        StreamLocalBindUnlink yes
      '';

      ports = [
        22
        # cfg.port
      ];
    };

    programs.ssh.extraConfig = ''
      Host *
        HostKeyAlgorithms +ssh-rsa

      ${optionalString cfg.manage-other-hosts other-hosts-config}
    '';

    frgd.user.extraOptions.openssh.authorizedKeys.keys =
      cfg.authorizedKeys;

    frgd.home.extraOptions = {
      programs.fish.shellAliases = foldl
        (aliases: system:
          aliases // {
            "ssh-${system}" = "ssh ${system} -t tmux a";
          })
        { }
        (builtins.attrNames other-hosts);
    };
  };
}
