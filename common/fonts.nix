# taken from github:sioodmy/dotfiles
{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      lexend
      lato
      noto-fonts
      noto-fonts-emoji
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

    enableDefaultPackages = false;

    fontconfig = {
      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
          "JetBrainsMono"
        ];

        sansSerif = [
          "Lexend"
          "Noto Color Emoji"
        ];
        serif = [
          "Noto Serif"
          "Noto Color Emoji"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
