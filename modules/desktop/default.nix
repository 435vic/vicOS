{
  config,
  lib,
  ...
}:
let
  cfg = config.vicos;
in
{
  imports = [
    ./apps.nix
    ./hyprland.nix
    ./lock.nix
    ./mime.nix
    ./user-dirs.nix
  ];

  options.vicos.desktop.enable = lib.mkEnableOption "the personal desktop applications and preferences";

  config = lib.mkIf cfg.desktop.enable {
    vicos.cli.enable = true;
    environment.sessionVariables.XCOMPOSECACHE = "$HOME/${cfg.xdg.cacheHome}/xcompose";
    environment.etc."environment.d/70-vicos-desktop.conf".text = ''
      XCOMPOSECACHE=$HOME/${cfg.xdg.cacheHome}/xcompose
    '';
    systemd.user.tmpfiles.rules = [
      ''d "%h/${cfg.xdg.cacheHome}/xcompose" :0700 - - -''
    ];
  };
}
