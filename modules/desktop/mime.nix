{ config, lib, ... }:
let
  cfg = config.vicos;
  apps = cfg.desktop.apps;
  associations = {
    "inode/directory" = apps.fileManager.desktop;
    "application/x-directory" = apps.fileManager.desktop;

    "text/plain" = apps.editor.desktop;
    "text/markdown" = apps.editor.desktop;
    "text/x-readme" = apps.editor.desktop;
    "text/html" = apps.browser.desktop;
    "text/xml" = apps.editor.desktop;
    "text/csv" = apps.editor.desktop;
    "text/x-c" = apps.editor.desktop;
    "text/x-c++" = apps.editor.desktop;
    "text/x-python" = apps.editor.desktop;
    "text/x-java" = apps.editor.desktop;
    "text/x-shellscript" = apps.editor.desktop;
    "application/json" = apps.editor.desktop;
    "application/yaml" = apps.editor.desktop;
    "application/x-yaml" = apps.editor.desktop;
    "application/toml" = apps.editor.desktop;
    "application/xml" = apps.editor.desktop;

    "application/pdf" = apps.pdfViewer.desktop;

    "image/png" = apps.imageViewer.desktop;
    "image/jpeg" = apps.imageViewer.desktop;
    "image/gif" = apps.imageViewer.desktop;
    "image/webp" = apps.imageViewer.desktop;
    "image/svg+xml" = apps.imageViewer.desktop;
    "image/bmp" = apps.imageViewer.desktop;

    "video/mp4" = apps.mediaPlayer.desktop;
    "video/x-matroska" = apps.mediaPlayer.desktop;
    "video/webm" = apps.mediaPlayer.desktop;
    "video/x-msvideo" = apps.mediaPlayer.desktop;
    "video/quicktime" = apps.mediaPlayer.desktop;
    "video/mpeg" = apps.mediaPlayer.desktop;

    "audio/mpeg" = apps.mediaPlayer.desktop;
    "audio/flac" = apps.mediaPlayer.desktop;
    "audio/ogg" = apps.mediaPlayer.desktop;
    "audio/wav" = apps.mediaPlayer.desktop;
    "audio/x-wav" = apps.mediaPlayer.desktop;
    "audio/mp4" = apps.mediaPlayer.desktop;

    "x-scheme-handler/http" = apps.browser.desktop;
    "x-scheme-handler/https" = apps.browser.desktop;
    "x-scheme-handler/mailto" = apps.mailClient.desktop;
  };
  entries = lib.concatLines (lib.mapAttrsToList (mime: desktop: "${mime}=${desktop};") associations);
in
{
  config = lib.mkIf (cfg.desktop.enable && cfg.user != null) {
    stash.users.${cfg.user}.files."${cfg.xdg.configHome}/mimeapps.list".text = ''
      [Default Applications]
      ${entries}
      [Added Associations]
      ${entries}
    '';
  };
}
