{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.services.mpd;
in {
  options.vicos.services.mpd = {
    enable = mkOption {
      type = types.bool;
      default = config.vicos.desktop.enable;
      description = "Whether to enable mpd";
    };
    mpris.enable = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Whether to enable MPRIS for mpd via mpd-mpris";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.mpd = {
        enable = true;
        musicDirectory = mkDefault "/home/${config.vicos.user.name}/music";
        extraConfig = ''
          audio_output {
            type "pipewire"
            name "default output"
          }
        '';

        # run mpd as main user, as pipewire doesn't normally run as system
        user = config.vicos.user.name;
      };

      systemd.services.mpd.environment = {
        XDG_RUNTIME_DIR = "/run/user/${toString config.vicos.user.uid}";
      };
    })
    (mkIf (cfg.enable && cfg.mpris.enable) {
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
    })
  ];
}
