{
  lib,
  config,
  ...
}: with lib; let
  cfg = config.vicos.services.mpd;
in {
  options.vicos.services.mpd = {
    enable = mkOption {
      type = types.bool;
      default = config.vicos.desktop.enable;
      description = "Whether to enable mpd";
    };
  };

  config = mkIf cfg.enable {
    services.mpd = {
      enable = true;
      musicDirectory = mkDefault "/home/${config.vicos.user.name}/Music";
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
  };
}
