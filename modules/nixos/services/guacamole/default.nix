{
  options,
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.frgd;
let
  cfg = config.frgd.services.guacamole;
  guacVer = pkgs.guacamole-client.version;

  headerAuthExtension = pkgs.stdenv.mkDerivation {
    pname = "guacamole-auth-header";
    version = guacVer;
    src = pkgs.fetchurl {
      url = "https://downloads.apache.org/guacamole/1.6.0/binary/guacamole-auth-header-${guacVer}.tar.gz";
      sha256 = "sha256-VMbqlEqrUVO9ogQB+ihAASitiWBrVwJ77iEnMntl+Vg=";
    };
    unpackPhase = ''
      tar -xzf $src
    '';
    installPhase = ''
      mkdir -p $out
      cp guacamole-auth-header-*/guacamole-auth-header-*.jar $out/
    '';
  };

  connectionXml =
    name: conn:
    let
      displayName = if conn.displayName != "" then conn.displayName else name;
      audioParams = optionalString conn.audioEnabled ''
        <param name="enable-audio">true</param>
        <param name="audio-servername">${conn.audioHost}</param>
        <param name="audio-port">${toString conn.audioPort}</param>
      '';
    in
    ''
      <connection name="${displayName}">
        <protocol>vnc</protocol>
        <param name="hostname">${conn.hostname}</param>
        <param name="port">${toString conn.port}</param>
        <param name="width">${toString conn.width}</param>
        <param name="height">${toString conn.height}</param>
        <param name="cursor">local</param>
        ${audioParams}
      </connection>
    '';

  allConnectionsXml = concatStringsSep "\n" (mapAttrsToList connectionXml cfg.connections);

  userMappingTemplate = pkgs.writeText "user-mapping.xml.tpl" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <user-mapping>
    ${
      if cfg.headerAuth.enable then
        concatStringsSep "\n" (
          map (user: ''
              <authorize username="${user}" password="" encoding="md5">
            ${allConnectionsXml}
              </authorize>'') cfg.headerAuth.authorizedUsers
        )
      else
        ''
            <authorize username="${cfg.username}" password="@GUACAMOLE_PASSWORD_HASH@" encoding="sha256">
          ${allConnectionsXml}
            </authorize>''
    }
    </user-mapping>
  '';

in
{
  options.frgd.services.guacamole = with types; {
    enable = mkBoolOpt false "Whether to enable the Guacamole remote desktop gateway.";

    guacdPort = mkOpt port 4822 "Port for the guacd backend daemon.";
    tomcatPort = mkOpt port 8080 "Port for the Tomcat/Guacamole web application (localhost only).";

    username =
      mkOpt str "admin"
        "Guacamole login username (password via SOPS secret 'guacamole_password').";

    connections = mkOpt (attrsOf (submodule {
      options = {
        displayName =
          mkOpt str ""
            "Human-readable name shown in the Guacamole UI (defaults to attrset key).";
        hostname =
          mkOpt str ""
            "Hostname or IP address of the VNC server (e.g., container bridge IP or LXD DNS name).";
        port = mkOpt port 5901 "VNC server port.";
        width = mkOpt int 1280 "Display width in pixels.";
        height = mkOpt int 800 "Display height in pixels.";
        audioEnabled = mkBoolOpt false "Enable PulseAudio forwarding for this connection.";
        audioHost =
          mkOpt str "127.0.0.1"
            "PulseAudio host inside the container (used when audioEnabled = true).";
        audioPort =
          mkOpt port 4713
            "PulseAudio TCP port inside the container (used when audioEnabled = true).";
      };
    })) { } "VNC connections that Guacamole will proxy.";

    headerAuth = {
      enable = mkBoolOpt false "Enable HTTP header authentication (e.g., for Tailscale).";
      headerName = mkOpt str "Tailscale-User-Login" "HTTP header containing the authenticated username.";
      authorizedUsers = mkOpt (listOf str) [ ] "List of authorized usernames for header authentication.";
    };
  };

  config = mkIf cfg.enable {

    assertions = [
      {
        assertion = cfg.connections != { };
        message = "frgd.services.guacamole: at least one connection must be defined.";
      }
      {
        assertion = all (conn: conn.hostname != "") (attrValues cfg.connections);
        message = "frgd.services.guacamole: all connections must have a non-empty hostname.";
      }
      {
        assertion = !cfg.headerAuth.enable || cfg.headerAuth.authorizedUsers != [ ];
        message = "frgd.services.guacamole: headerAuth.authorizedUsers must be set when headerAuth is enabled.";
      }
    ];

    services.guacamole-server = {
      enable = true;
      host = "127.0.0.1";
      port = cfg.guacdPort;
    };

    services.guacamole-client = {
      enable = true;
      enableWebserver = true;
      settings =
        let
          base = {
            guacd-hostname = "localhost";
            guacd-port = cfg.guacdPort;
          };
          extra =
            if cfg.headerAuth.enable then
              {
                extension-priority = "user-mapping,header";
                http-auth-header = cfg.headerAuth.headerName;
              }
            else
              {
                extension-priority = "user-mapping";
              };
        in
        base // extra;
      userMappingXml = "/etc/guacamole/user-mapping.xml";
    };

    environment.etc."guacamole/extensions/guacamole-auth-header-${guacVer}.jar".source =
      "${headerAuthExtension}/guacamole-auth-header-${guacVer}.jar";

    sops.secrets.guacamole_password = {
      owner = "root";
      mode = "0400";
    };

    system.activationScripts.guacamole-user-mapping = {
      deps = [ "setupSecrets" ];
      text =
        let
          passwordPath = config.sops.secrets.guacamole_password.path;
        in
        ''
          rm -f /etc/guacamole/user-mapping.xml
          install -d -m 755 /etc/guacamole
          PASSWORD_HASH=$(${pkgs.coreutils}/bin/cat ${passwordPath} | ${pkgs.openssl}/bin/openssl dgst -sha256 -hex | ${pkgs.gawk}/bin/awk '{print $2}')
          ${pkgs.gnused}/bin/sed "s/@GUACAMOLE_PASSWORD_HASH@/$PASSWORD_HASH/" ${userMappingTemplate} > /etc/guacamole/user-mapping.xml
          ${pkgs.coreutils}/bin/chmod 644 /etc/guacamole/user-mapping.xml
        '';
    };
  };
}
