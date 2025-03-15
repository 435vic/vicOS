{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.vicos.desktop.term;
in
{
  options.vicos.desktop.term = {
    ghostty = {
      enable = mkEnableOption "ghostty";
    };
  };

  config = {
    vicos.desktop.hyprland.defaultTerm = if cfg.ghostty.enable then "ghostty" else "alacritty";

    environment.systemPackages = [
      (if cfg.ghostty.enable then pkgs.unstable.ghostty else pkgs.unstable.alacritty)
    ];

    home.file = mkMerge [
      (mkIf cfg.ghostty.enable {
        "ghostty/config".source = config.lib.vicos.fileFromConfig "ghostty/config";
      })
    ];
  };
}