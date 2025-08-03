{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.desktop.rofi;
in {
  options.vicos.desktop.rofi.enable = mkEnableOption "rofi";

  config = mkIf cfg.enable (mkMerge [
    {
      home.configFile."rofi" = {
        source = config.lib.vicos.dirFromConfig "rofi";
        recursive = true;
      };

      # without this rofi won't show svg icons
      programs.gdk-pixbuf.modulePackages = [pkgs.librsvg];

      vicos.user.packages = with pkgs.unstable; [
        rofi-wayland-unwrapped
        #(rofimoji.override {rofi = rofi-wayland-unwrapped;})
      ];
    }

    (mkIf config.hardware.bluetooth.enable {
      vicos.user.packages = [
        (pkgs.makeDesktopItem {
          desktopName = "  manage bluetooth";
          name = "rofi-bluetooth";
          icon = "bluetooth";
          exec = "${pkgs.rofi-bluetooth}/bin/rofi-bluetooth";
        })
      ];
    })
  ]);
}
