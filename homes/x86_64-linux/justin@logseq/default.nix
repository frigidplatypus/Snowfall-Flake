{ lib, pkgs, ... }:
with lib;
with lib.frgd;
{
  frgd = {
    user = {
      enable = true;
      name = "justin";
    };

    suites.common = enabled;

    security = {
      sops = {
        enable = true;
      };
    };

    cli-apps = {
      tmux = enabled;
      ai-tools = enabled;
      yazi = enabled;
    };

    tools = {
      git = {
        enable = true;
        internalGitKey = true;
      };
      misc = enabled;
      charms = enabled;
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Justin Martin";
        email = "jus10mar10@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
    };
  };

  xdg.configFile."openbox/menu.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <openbox_menu xmlns="http://openbox.org/3.4/menu">
      <menu id="root-menu" label="Menu">
        <item label="Terminal"><action name="Execute"><command>xterm</command></action></item>
        <item label="Logseq"><action name="Execute"><command>logseq</command></action></item>
        <item label="Obsidian"><action name="Execute"><command>obsidian</command></action></item>
        <separator />
        <item label="Reboot"><action name="Execute"><command>systemctl reboot</command></action></item>
        <item label="Shutdown"><action name="Execute"><command>systemctl poweroff</command></action></item>
        <separator />
        <item label="Logout"><action name="Execute"><command>openbox --exit</command></action></item>
      </menu>
    </openbox_menu>
  '';

  home.file."bin/logseq-sync.sh".text = ''
    #!/bin/bash
    set -e
    cd ~/logseq
    git fetch
    git pull --rebase
    git push
  '';

  systemd.user.services.logseq-sync = {
    Unit = {
      Description = "Git pull/push for Logseq";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash %h/bin/logseq-sync.sh";
    };
    Install = {
      WantedBy = [ "multi-user.target" ];
    };
  };

  systemd.user.timers.logseq-sync = {
    Unit = {
      Description = "Timer for Logseq git sync";
    };
    Timer = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
