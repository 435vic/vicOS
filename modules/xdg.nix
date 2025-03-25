{
  config,
  pkgs,
  lib,
  ...
}: with lib; let
  cfg = config.vicos.xdg;
in {
  options.vicos.xdg = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable xdg compliance.";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [pkgs.xdg-user-dirs];

      sessionVariables.__GL_SHADER_DISK_CACHE_PATH = "/tmp/nv";
    };
  };

  home.configFile."user-dirs.dirs".text = ''
    XDG_DESKTOP_DIR="${home.fakeDir}/Desktop"
    XDG_DOCUMENTS_DIR="${home.fakeDir}/Documents"
    XDG_DOWNLOAD_DIR="${home.fakeDir}/Downloads"
    XDG_MUSIC_DIR="${home.fakeDir}/Music"
    XDG_PICTURES_DIR="${home.fakeDir}/Pictures"
    XDG_PUBLICSHARE_DIR="${home.fakeDir}/Share"
    XDG_TEMPLATES_DIR="${home.fakeDir}/Templates"
    XDG_VIDEOS_DIR="${home.fakeDir}/Videos"
  '';

  system.userActivationScripts.initXDG = ''
    for dir in "$XDG_DESKTOP_DIR" "$XDG_STATE_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME" "$XDG_BIN_HOME" "$XDG_CONFIG_HOME"; do
      mkdir -p "$dir" -m 700
        done

      # Populate the fake home with .local and .config, so certain things are
      # still in scope for the jailed programs, like fonts, data, and files,
      # should they choose to use them at all.
      fakehome="${home.fakeDir}"
      mkdir -p "$fakehome" -m 755
      [ -e "$fakehome/.local" ]  || ln -sf ~/.local  "$fakehome/.local"
      [ -e "$fakehome/.config" ] || ln -sf ~/.config "$fakehome/.config"

      # Avoid the creation of ~/.pki (typically by Firefox), by ensuring NSS
      # finds this directory.
      rm -rf "$HOME/.pki"
      mkdir -p "$XDG_DATA_HOME/pki/nssdb"
  '';
}
