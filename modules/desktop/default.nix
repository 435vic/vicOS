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
  imports = [
    ./browser.nix
    ./hyprland.nix
    ./term.nix
    ./gaming.nix
  ];

  options.vicos.desktop = {
    enable = mkEnableOption "Desktop environment";
    wayland.enable = mkEnableOption "Wayland";
    xorg.enable = mkEnableOption "X11";
  };

  config = mkIf cfg.enable (mkMerge [
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
  ]);
}
