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
    description = "Music Player Daemon";
    after = [
      "network.target"
      "sound.target"
      "mpd.socket"
    ];
    requires = [ "mpd.socket" ];

    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon %h/.config/mpd/mpd.conf";
    };
  };

  systemd.user.sockets.mpd = {
    wantedBy = [ "sockets.target" ];

    socketConfig = {
      ListenStream = [ "127.0.0.1:6600" "%t/mpd/socket" ];
      Backlog = 5;
      KeepAlive = true;
    };
  };

  home.configFile."mpd/mpd.conf".source =
    config.lib.vicos.stash "config/mpd/mpd.conf";
}
