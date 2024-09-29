{
  pkgs,
  libs,
  ...
}:
{
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

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
