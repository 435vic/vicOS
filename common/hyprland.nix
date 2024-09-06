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
    swaynotificationcenter
    grim
    brightnessctl
    rofi-wayland
    hyprpaper
    waybar
    libnotify
    networkmanagerapplet
    libsForQt5.qt5.qtwayland
    kdePackages.qtwayland
    swappy
    slurp
    wf-recorder
    kdePackages.polkit-kde-agent-1
    xdg-desktop-portal-gtk
    adwaita-qt
    adwaita-qt6
  ];
}
