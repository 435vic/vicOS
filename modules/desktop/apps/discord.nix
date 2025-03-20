{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vicos.desktop.apps.discord;
in {
  options.vicos.desktop.apps.discord = {
    enable = mkEnableOption "discord (via legcord)";
  };

  config = mkIf cfg.enable {
    # cant use unstable bc of libgm
    # TODO: switch to unstable version once mesa >= 24.3 is in nixos stable
    environment.systemPackages = [pkgs.legcord];
  };
}
