{
  pkgs,
  inputs,
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
          inputs.nix-gaming.packages.${pkgs.system}.northstar-proton
        }'";
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    bottles
    protonup
    mangohud
    r2modman
  ];

  environment.sessionVariables = {
    GAMEMODERUNEXEC = "nvidia-offload";
  };
}
