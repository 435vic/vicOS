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
      packages = mkOption {
        type = with types; listOf package;
        default = [];
        description = "List of packages to install for gaming";
      };

      tetrio.enable = mkEnableOption "Tetr.io";
  };

  config = mkIf cfg.enable {
    vicos.desktop.gaming.packages = with pkgs; mkDefault [
      bottles
      protonup
      mangohud
      r2modman
      lutris
      (mkIf cfg.tetrio.enable (pkgs.tetrio-desktop.overrideAttrs (previousAttrs: {
        installPhase =
          builtins.replaceStrings [ "Exec=$out/bin/tetrio" ] [ "Exec=gamemoderun $out/bin/tetrio" ] previousAttrs.installPhase;
      })))
    ];

    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;

    # should probably be determined by an nvidia option
    environment.sessionVariables = {
      GAMEMODERUNEXEC = "nvidia-offload";
    };

    environment.systemPackages = cfg.packages;
  };
}