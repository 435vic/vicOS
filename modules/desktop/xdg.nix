{
  pkgs,
  lib,
  config,
  ...
}:
let
  user = config.vicos.user;
  homeDir = config.users.users.${user}.home;
  userDir = "${homeDir}/.local/user";
  screenshotDir = "${homeDir}/pictures/screenshots";
in
{
  environment.systemPackages = [ pkgs.xdg-user-dirs ];

  environment.sessionVariables = {
    HYPRSHOT_DIR = screenshotDir;
  };

  systemd.tmpfiles.rules = [
    "d ${screenshotDir} 0755 ${user} users -"
    "d ${userDir} 0755 ${user} users -"
  ];

  home.configFile."user-dirs.dirs".text = ''
    XDG_DESKTOP_DIR="${userDir}"
    XDG_DOCUMENTS_DIR="${userDir}"
    XDG_DOWNLOAD_DIR="${userDir}"
    XDG_MUSIC_DIR="${userDir}"
    XDG_PICTURES_DIR="${homeDir}/pictures"
    XDG_PUBLICSHARE_DIR="${userDir}"
    XDG_TEMPLATES_DIR="${userDir}"
    XDG_VIDEOS_DIR="${userDir}"
  '';

  home.configFile."user-dirs.locale".text = "en_US";

  home.configFile."mimeapps.list".text =
    let
      associations = {
        "text/plain" = "zeditor.desktop";
        "text/markdown" = "zeditor.desktop";
        "text/x-readme" = "zeditor.desktop";
        "text/html" = "helium.desktop";
        "text/xml" = "zeditor.desktop";
        "text/csv" = "zeditor.desktop";
        "text/x-c" = "zeditor.desktop";
        "text/x-c++" = "zeditor.desktop";
        "text/x-python" = "zeditor.desktop";
        "text/x-java" = "zeditor.desktop";
        "text/x-shellscript" = "zeditor.desktop";
        "application/json" = "zeditor.desktop";
        "application/x-yaml" = "zeditor.desktop";
        "application/toml" = "zeditor.desktop";
        "application/xml" = "zeditor.desktop";

        "application/pdf" = "helium.desktop";

        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/svg+xml" = "imv.desktop";
        "image/bmp" = "imv.desktop";

        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";
        "video/mpeg" = "mpv.desktop";

        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
        "audio/wav" = "mpv.desktop";
        "audio/x-wav" = "mpv.desktop";
        "audio/mp4" = "mpv.desktop";

        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";


      };

      formatEntries = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (mime: app: "${mime}=${app}") associations
      );
    in
    ''
      [Default Applications]
      ${formatEntries}

      [Added Associations]
      ${formatEntries}
    '';
}
