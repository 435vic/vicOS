{
  config,
  pkgs,
  lib,
  ...
}: with lib; let
  cfg = config.vicos.theme;
in mkIf (cfg.active == "rose-pine") {
  vicos.theme = {
    gtk = {
      package = pkgs.rose-pine-gtk-theme;
      iconPackage = pkgs.rose-pine-icon-theme;
      name = "rose-pine";
      iconName = "oomox-rose-pine";
    };

    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "rose-pine-cursor";
      hyprcursorPackage = pkgs.rose-pine-hyprcursor;
      hyprcursorName = "rose-pine-hyprcursor";
    };
  };
}
