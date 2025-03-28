{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.desktop;
in {
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
        playerctl
        zed-editor.fhs #FIXME: move somewhere else maybe?
      ];

      services.udisks2.enable = true;
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
