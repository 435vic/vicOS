{ pkgs, config, ... }:
{
  # TODO: add alternate launcher options (walker?)
  home.configFile.rofi = {
    source = config.lib.vicos.stash "config/rofi";
    recursive = true;
  };

  programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

  environment.systemPackages = [
    pkgs.rofi-unwrapped
  ];
}
