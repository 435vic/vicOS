{
  pkgs,
  libs,
  ...
}:
{
  # Most proton games (or games in general)
  # use X11 for windowing, so using it directly instead
  # of xwayland is probably a good idea.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.xserver.displayManager.startx.enable = true;
}
