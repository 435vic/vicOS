{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.vicos.desktop.hyprland;
in {
  options.vicos.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland";
  };

  config = mkIf cfg.enable {
    vicos.desktop.wayland.enable = true;

    environment.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };

    # the newer versions of hyprland require recent mesa drivers
    hardware.graphics = {
      package = pkgs.unstable.mesa.drivers;
      package32 = pkgs.unstable.pkgsi686Linux.mesa.drivers;
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = pkgs.unstable.hyprland;
      portalPackage = pkgs.unstable.xdg-desktop-portal-hyprland;
    };

    environment.systemPackages = with pkgs.unstable; [
      hyprlock      # lock screem
      hyprpaper     # wallpaper manager
      hyprpicker    # color picker
      hyprshot      # screenshot tool

      mako          # notification daemon
      pamixer       # volume control
    ];

    home.configFile = {
      hypr = {
        source = config.lib.vicos.dirFromConfig "hypr";
        recursive = true;
      };
    };
  };
}