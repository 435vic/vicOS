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
    ./gaming.nix
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
    # ly includes the login stack. Keep daemon startup, but never pass account
    # passwords to a passwordless keyring: a password-based login would
    # silently re-encrypt it on save.
    security.pam.services.login.rules = {
      auth.gnome_keyring.enable = lib.mkForce false;
      password.gnome_keyring.enable = lib.mkForce false;
    };

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
