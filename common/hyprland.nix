{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
{
  imports = [
    ../scripts/hyprland
  ];

  programs.hyprland = {
    enable = true;
    #package = inputs.hyprland.packages.${system}.hyprland;
    #portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  };

  # Enable Ozone Wayland support in Chromium and Electron based applications
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Adwaita";
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "Adwaita-Dark";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  programs.nm-applet.enable = true;
  networking.networkmanager.enable = true;

  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    dunst # notifs
    grimblast # screenshot utility
    grim # screenshots
    slurp # area screenshots
    wl-clipboard # copy images to clipboard
    brightnessctl # keyboard and monitor brightness
    rofi-wayland # app launcher
    hyprpaper # wallpaper
    waybar # status bar
    libnotify # notify-send
    libsForQt5.qt5.qtwayland # qt5 support
    kdePackages.qtwayland # qt6 support
    swappy # screenshot editor
    wf-recorder # wayland screen recorder
    polkit_gnome # authentication/keychain
    playerctl # play/pause
    pamixer # audio config
    xdotool # window management for steam
    xdg-desktop-portal-gtk # file picker dialog
    adwaita-qt # qt5 dark theme
    adwaita-qt6 # qt6 dark theme
    btop # process/computer monitor
    papirus-icon-theme # icon theme
    pavucontrol # graphical audio interface config
    nemo # file manager
    gnome-themes-extra # Adwaita theme
    networkmanagerapplet # nm-applet
    udiskie # removable media manager
  ];

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.hyprland.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Autostart gnome polkit auth agent
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
