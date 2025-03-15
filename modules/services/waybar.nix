{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.vicos.services.waybar;
in {
  options.vicos.services.waybar = {
    enable = mkEnableOption "waybar";
    package = mkOption {
      type = types.package;
      default = pkgs.waybar;
      description = "The waybar package to use";
    };
    settings = mkOption {
      type = with types; attrsOf anything;
      description = "Additional settings for waybar";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.vicos.desktop.wayland.enable;
        message = "waybar requires a wayland desktop";
      }
    ];

    programs.waybar = {
      enable = true;
      package = cfg.package;
    };

    home.configFile.waybar = {
      source = config.lib.vicos.dirFromConfig "waybar";
      recursive = true;
    };
  };
}