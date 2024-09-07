{
  pkgs,
  lib,
  inputs,
  system,
  ...
}:
{
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

  environment.systemPackages = with pkgs; [
    swaynotificationcenter # notifs
    grimblast # screenshots
    brightnessctl # keyboard and monitor brightness
    rofi-wayland # app launcher
    hyprpaper # wallpaper
    waybar # status bar
    libnotify # notify-send
    networkmanagerapplet # configure networks from swaybar
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
  ];
}
