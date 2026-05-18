{
  pkgs,
  lib,
  config,
  ...
}: let
  user = config.vicos.user;
  homeDir = config.users.users.${user}.home;
  userDir = "${homeDir}/.local/user";
  screenshotDir = "${homeDir}/pictures/screenshots";
  apps = config.vicos.desktop.apps;
in {
  environment.systemPackages = [pkgs.xdg-user-dirs];

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

  home.configFile."mimeapps.list".text = let
    editor = apps.editor.desktop;
    browser = apps.browser.desktop;
    fileManager = apps.fileManager.desktop;
    imageViewer = apps.imageViewer.desktop;
    mailClient = apps.mailClient.desktop;
    mediaPlayer = apps.mediaPlayer.desktop;
    pdfViewer = apps.pdfViewer.desktop;

    associations = {
      "inode/directory" = fileManager;
      "application/x-directory" = fileManager;

      "text/plain" = editor;
      "text/markdown" = editor;
      "text/x-readme" = editor;
      "text/html" = browser;
      "text/xml" = editor;
      "text/csv" = editor;
      "text/x-c" = editor;
      "text/x-c++" = editor;
      "text/x-python" = editor;
      "text/x-java" = editor;
      "text/x-shellscript" = editor;
      "application/json" = editor;
      "application/x-yaml" = editor;
      "application/toml" = editor;
      "application/xml" = editor;

      "application/pdf" = pdfViewer;

      "image/png" = imageViewer;
      "image/jpeg" = imageViewer;
      "image/gif" = imageViewer;
      "image/webp" = imageViewer;
      "image/svg+xml" = imageViewer;
      "image/bmp" = imageViewer;

      "video/mp4" = mediaPlayer;
      "video/x-matroska" = mediaPlayer;
      "video/webm" = mediaPlayer;
      "video/x-msvideo" = mediaPlayer;
      "video/quicktime" = mediaPlayer;
      "video/mpeg" = mediaPlayer;

      "audio/mpeg" = mediaPlayer;
      "audio/flac" = mediaPlayer;
      "audio/ogg" = mediaPlayer;
      "audio/wav" = mediaPlayer;
      "audio/x-wav" = mediaPlayer;
      "audio/mp4" = mediaPlayer;

      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/mailto" = mailClient;
    };

    formatEntries = lib.concatStringsSep "\n" (
      lib.mapAttrsToList (mime: app: "${mime}=${app};") associations
    );
  in ''
    [Default Applications]
    ${formatEntries}

    [Added Associations]
    ${formatEntries}
  '';
}
