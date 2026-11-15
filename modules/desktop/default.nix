{
  config,
  lib,
  pkgs,
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
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
    hardware.graphics = {
      enable = true;
      enable32Bit = pkgs.stdenv.hostPlatform.isx86_64;
    };
    services.udisks2.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.gnome.gcr-ssh-agent.enable = false;
    security.pam.services.ly.enableGnomeKeyring = true;

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ];
    environment.sessionVariables = {
      XCOMPOSECACHE = "$HOME/${cfg.xdg.cacheHome}/xcompose";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
      HYPRSHOT_DIR = "$HOME/pictures/screenshots";
    };
    environment.etc."environment.d/70-vicos-desktop.conf".text = ''
      XCOMPOSECACHE=$HOME/${cfg.xdg.cacheHome}/xcompose
      NIXOS_OZONE_WL=1
      MOZ_ENABLE_WAYLAND=1
      HYPRSHOT_DIR=$HOME/pictures/screenshots
    '';
    systemd.user.tmpfiles.rules = [
      ''d "%h/${cfg.xdg.cacheHome}/xcompose" :0700 - - -''
    ];
  };
}
