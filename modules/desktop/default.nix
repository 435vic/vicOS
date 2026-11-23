{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vicos;
  gtkSettings = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=adw-gtk3-dark
    gtk-icon-theme-name=Papirus-Dark
    gtk-cursor-theme-name=Marathon-bold
  '';
in
{
  imports = [
    ./apps.nix
    ./gaming.nix
    ./hyprland.nix
    ./lock.nix
    ./pond.nix
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

    # Fixed look carried over from main: dark Adwaita for GTK and Qt, Papirus icons
    # and the Marathon cursor. Hyprland syncs XCURSOR_THEME into gsettings.
    environment.systemPackages = [
      pkgs.adw-gtk3
      pkgs.papirus-icon-theme
      (pkgs.callPackage ../../packages/marathon-cursor { })
    ];
    programs.dconf.profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Papirus-Dark";
          cursor-theme = "Marathon-bold";
        };
      }
    ];
    environment.etc."xdg/gtk-3.0/settings.ini".text = gtkSettings;
    environment.etc."xdg/gtk-4.0/settings.ini".text = gtkSettings;
    # Dark Adwaita for Qt 5 and 6 (sets QT_STYLE_OVERRIDE).
    qt = {
      enable = true;
      style = "adwaita-dark";
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
      XCURSOR_THEME = "Marathon-bold";
    };
    environment.etc."environment.d/70-vicos-desktop.conf".text = ''
      XCURSOR_THEME=Marathon-bold
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
