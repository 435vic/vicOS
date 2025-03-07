{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.vicos.desktop;
in
{
  options.vicos.desktop = {
    enable = mkEnableOption "Desktop environment";
    wayland.enable = mkEnableOption "Wayland";
    xorg.enable = mkEnableOption "X11";
  };

  assertions = [
    {
      assertion = !cfg.desktop.enable || cfg.wayland.enable || cfg.xorg.enable;
      message = "Desktop environment was enabled but neither Wayland nor X11 is enabled";
    }
    {
      assertion = (cfg.wayland.enable || cfg.xorg.enable) && !cfg.desktop.enable;
      message = "Desktop must be enabled to use Wayland or X11";
    }
  ];

  config = mkIf cfg.enable mkMerge [
    {
      environment.systemPackages = with pkgs; [
        libnotify
        xdg-utils
      ];
    }

    (mkIf cfg.wayland.enable {
      environment.systemPackages = with pkgs; [
        ripdrag # drag and drop
        wev # wayland event viewer
        wl-clipboard # clipboard
        swappy # screenshot tool
        slurp
        grim
        swayimg
        imv # image viewer
      ];
    })

    # TODO: X11
  ];
}