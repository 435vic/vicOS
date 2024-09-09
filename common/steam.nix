{
  pkgs,
  libs,
  ...
}:
{
  # Configure openGL for better gaming support
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  environment.systemPackages = with pkgs; [
    bottles
    protonup
    gamemode
  ];
}
