{ pkgs, ... }:
{
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      protonup-ng
      mangohud
      r2modman
      prismlauncher
      ;

    tetrio = pkgs.tetrio-desktop.overrideAttrs (previousAttrs: {
      installPhase =
        builtins.replaceStrings [ "Exec=$out/bin/tetrio" ] [ "Exec=gamemoderun $out/bin/tetrio" ]
          previousAttrs.installPhase;
    });
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
}
