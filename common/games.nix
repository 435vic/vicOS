{
  pkgs,
  inputs,
  outputs,
  libs,
  ...
}:
{
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # enables the Northstar proton build for Titanfall 2
  nixpkgs.overlays = [
    (_: prev: {
      steam = prev.steam.override {
        extraProfile = "export STEAM_EXTRA_COMPAT_TOOLS_PATHS='${
          outputs.packages.${pkgs.system}.northstar-proton
        }'";
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    bottles
    protonup
    mangohud
    r2modman
    local.viper # tf2 northstar/mod manager
    lutris
    # tetr.io desktop with gamemode
    (tetrio-desktop.overrideAttrs (previousAttrs: {
      installPhase =
        builtins.replaceStrings [ "Exec=$out/bin/tetrio" ] [ "Exec=gamemoderun $out/bin/tetrio" ]
          previousAttrs.installPhase;
    }))
  ];

  environment.sessionVariables = {
    GAMEMODERUNEXEC = "nvidia-offload";
  };
}
