{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.vicos.desktop.gaming;
in
{
  options.vicos.desktop.gaming = {
      enable = mkEnableOption "Gaming";
      enableExtraPackages = mkEnableOption "Enable extra packages";

      tetrio.enable = mkEnableOption "Tetr.io";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = mkIf cfg.enableExtraPackages (with pkgs.unstable; [
      bottles
      protonup
      mangohud
      r2modman
      lutris
      (mkIf cfg.tetrio.enable (tetrio-desktop.overrideAttrs (previousAttrs: {
        installPhase =
          builtins.replaceStrings [ "Exec=$out/bin/tetrio" ] [ "Exec=gamemoderun $out/bin/tetrio" ] previousAttrs.installPhase;
      })))
    ]);

    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;

    # should probably be determined by an nvidia option
    environment.sessionVariables = {
      GAMEMODERUNEXEC = "nvidia-offload";
    };
  };
}