{ pkgs, lib, config, ... }: {
  systemd.user.services.mpd-mpris = {
    wantedBy = ["default.target"];

    description = "An MPRIS protocol implementation for the MPD music player";
    after = ["mpd.service"];

    serviceConfig = {
      Type = "dbus";
      Restart = "on-failure";
      RestartSec = "5s";
      ExecStart = "${pkgs.mpd-mpris}/bin/mpd-mpris -no-instance";
      BusName = "org.mpris.MediaPlayer2.mpd";
    };
  };

  systemd.user.services.mpd = {
    Unit = {
      Description = "Music Player Daemon";
      After = [
        "network.target"
        "sound.target"
        "mpd.socket"
      ];
      Requires = [ "mpd.socket" ];
    };

    Service = {
      Type = "notify";
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon $XDG_CONFIG_HOME/mpd/mpd.conf";
    };
  };

  systemd.user.sockets.mpd = {
    Socket = {
      ListenStream = [ "127.0.0.1:6600" "%t/mpd/socket" ];
      Backlog = 5;
      KeepAlive = true;
    };

    Install.WantedBy = [ "sockets.target" ];
  };

  home.configFile."mpd/mpd.conf".source =
    config.lib.vicos.stash "mpd/mpd.conf";

  systemd.services.mpd.environment = {
    XDG_RUNTIME_DIR = "/run/user/${toString config.vicos.user.uid}";
  };
}
