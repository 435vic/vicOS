{
config,
lib,
pkgs,
...
}:
with lib;
let
  cfg = config.vicos.desktop.apps.discord;
in
{
  options.vicos.desktop.apps.discord = {
    enable = mkEnableOption "discord (via legcord)";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.unstable.legcord ];
  };
}