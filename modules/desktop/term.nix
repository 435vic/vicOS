{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.vicos.desktop.term;
in {
  options.vicos.desktop.term = {
    ghostty = {
      enable = mkEnableOption "ghostty";
      package = mkOption {
        type = types.package;
        default = pkgs.unstable.ghostty;
        description = "The ghostty package to use.";
      };
    };
  };

  config = {
    vicos.desktop.hyprland.defaultTerminal =
      if cfg.ghostty.enable
      then "ghostty"
      else "alacritty";

    environment.systemPackages = [
      (
        if cfg.ghostty.enable
        then cfg.ghostty.package
        else pkgs.unstable.alacritty
      )
    ];

    home.configFile = mkMerge [
      (mkIf cfg.ghostty.enable {
        "ghostty/config".source = config.lib.vicos.fileFromConfig "ghostty/config";
      })
    ];
  };
}
