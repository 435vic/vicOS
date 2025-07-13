{
  config,
  lib,
  pkgs,
  ...
}: with lib; let
  cfg = config.vicos.desktop.music;
in {
  options.vicos.desktop.music = {
    enable = mkEnableOption "Music stuff";
  };

  config = mkIf cfg.enable {
    vicos.services.mpd.enable = true; 

    vicos.user.packages = with pkgs; [
      beets
      yt-dlp
      rmpc
    ];

    home.configFile = {
      beets = {
        source = config.lib.vicos.dirFromConfig "beets";
        recursive = true;
      };

      rmpc = {
        source = config.lib.vicos.dirFromConfig "rmpc";
        recursive = true;
      };
    };
  };
}
