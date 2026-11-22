{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
  user = config.users.users.${cfg.user};
  folders = {
    DESKTOP = "desktop";
    DOCUMENTS = "documents";
    DOWNLOAD = "downloads";
    MUSIC = "music";
    PICTURES = "pictures";
    PUBLICSHARE = "public";
    TEMPLATES = "templates";
    VIDEOS = "videos";
  };
in
{
  config = lib.mkIf (cfg.desktop.enable && cfg.user != null) {
    users.users.${cfg.user}.packages = [ pkgs.xdg-user-dirs ];

    systemd.tmpfiles.rules = map (
      folder: ''d "${user.home}/${folder}" :0700 :${cfg.user} :${user.group} - -''
    ) (builtins.attrValues folders ++ [ "pictures/screenshots" ]);

    stash.users.${cfg.user}.files = {
      "${cfg.xdg.configHome}/user-dirs.dirs".text = lib.concatLines (
        lib.mapAttrsToList (name: folder: ''XDG_${name}_DIR="$HOME/${folder}"'') folders
      );
      # Keep login helpers from rewriting these declarative paths.
      "${cfg.xdg.configHome}/user-dirs.conf".text = ''
        enabled=False
        filename_encoding=UTF-8
      '';
    };
  };
}
