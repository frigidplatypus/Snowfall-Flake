{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}:
with lib;
with lib.frgd;
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  systemd.services.guacamole-vnc = {
    description = "Xvfb with Openbox and x11vnc for Guacamole";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "justin";
      Group = "users";
      ExecStart = pkgs.writeScript "start-vnc.sh" ''
        #!${pkgs.bash}/bin/bash
        export HOME=/home/justin
        export DISPLAY=:99
        export XDG_CONFIG_HOME=/etc/xdg
        export XAUTHORITY=/home/justin/.Xauthority

        # Clean up old lock files
        rm -f /tmp/.X99-lock /tmp/.X99-:99

        touch /home/justin/.Xauthority
        chown justin:users /home/justin/.Xauthority

        rm -rf /home/justin/.config/openbox

        PATH=${pkgs.xvfb}/bin:${pkgs.openbox}/bin:${pkgs.xterm}/bin:${pkgs.x11vnc}/bin:${pkgs.logseq}/bin:${pkgs.obsidian}/bin:$PATH

        Xvfb :99 -screen 0 1024x768x24 &
        XVFB_PID=$!
        sleep 2

        x11vnc -display :99 -forever -shared &
        sleep 1

        openbox &

        xterm &
        ${pkgs.logseq}/bin/logseq &
        ${pkgs.obsidian}/bin/obsidian &

        wait $XVFB_PID
      '';
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  environment.systemPackages = with pkgs; [
    x11vnc
    openbox
    xterm
    xvfb
    obsidian
    git
  ];

  services.xserver.enable = true;
  services.xserver.windowManager.openbox.enable = true;

  environment.etc."xdg/openbox/rc.xml".source = pkgs.writeText "rc.xml" ''
    <?xml version="1.0"?>
    <openbox_config xmlns="http://openbox.org/3.4/rc">
      <resistance><enable>yes</enable></resistance>
      <focus><focusNew>yes</focusNew></focus>
      <menu><file>menu.xml</file></menu>
    </openbox_config>
  '';

  environment.etc."xdg/openbox/menu.xml".source = pkgs.writeText "menu.xml" ''
    <?xml version="1.0"?>
    <openbox_menu>
      <menu id="root" label="Menu">
        <item label="Logseq" exec="${pkgs.logseq}/bin/logseq"/>
        <item label="Obsidian" exec="${pkgs.obsidian}/bin/obsidian"/>
        <separator/>
        <item label="Terminal" exec="xterm"/>
        <separator/>
        <item label="Reboot" exec="systemctl reboot"/>
        <item label="Shutdown" exec="systemctl poweroff"/>
        <separator/>
        <item label="Logout" exec="openbox --exit"/>
      </menu>
    </openbox_menu>
  '';

  environment.etc."xdg/openbox/autostart".source = pkgs.writeText "autostart" ''
    #!${pkgs.bash}/bin/bash
    export PATH=${pkgs.xterm}/bin:${pkgs.logseq}/bin:${pkgs.obsidian}/bin:$PATH
    xterm &
    ${pkgs.logseq}/bin/logseq &
    ${pkgs.obsidian}/bin/obsidian &
  '';

  services.guacamole-server = {
    enable = true;
    host = "127.0.0.1";
  };

  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    settings = {
      guacd-hostname = "127.0.0.1";
      guacd-port = 4822;
    };
    userMappingXml = pkgs.writeText "user-mapping.xml" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <user-mapping>
        <authorize username="guacuser" password="5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8" encoding="sha256">
          <connection name="Openbox VNC">
            <protocol>vnc</protocol>
            <param name="hostname">localhost</param>
            <param name="port">5900</param>
          </connection>
        </authorize>
      </user-mapping>
    '';
  };

  services.caddy = {
    enable = true;
    virtualHosts = {
      "logseq.${tailnet}" = {
        extraConfig = ''
          rewrite * /guacamole{uri}
          reverse_proxy http://127.0.0.1:8080
          encode gzip
        '';
      };
    };
  };

  frgd = {
    nix = enabled;
    archetypes.lxc = enabled;
    apps.logseq = enabled;
    tools.git = {
      enable = true;
      userName = "Justin Martin";
      userEmail = "jus10mar10@gmail.com";
    };
  };
}
